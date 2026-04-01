import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';
import { ethers } from 'ethers';

dotenv.config();

const app = express();
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
const allowAllOrigins = allowedOrigins.length === 0 || allowedOrigins.includes('*');

app.set('trust proxy', 1);
app.use(helmet());

app.use(cors({
  origin(origin, cb) {
    if (!origin) return cb(null, true);
    if (allowAllOrigins) return cb(null, true);
    return allowedOrigins.includes(origin)
      ? cb(null, true)
      : cb(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));

function parseBooleanEnv(value, fallback = false) {
  if (value == null || value === '') return fallback;
  const normalized = String(value).trim().toLowerCase();
  if (['1', 'true', 'yes', 'y', 'on'].includes(normalized)) return true;
  if (['0', 'false', 'no', 'n', 'off'].includes(normalized)) return false;
  return fallback;
}

function getPublicBaseUrl(req) {
  const configured = String(process.env.PUBLIC_BASE_URL || '').trim();
  if (configured) return configured.replace(/\/$/, '');
  return `${req.protocol}://${req.get('host')}`;
}

function checkoutLandingHtml({ title, message, emoji }) {
  return `<!doctype html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${title}</title>
    <style>
      body { font-family: Arial, sans-serif; background:#0b1220; color:#fff; margin:0; display:grid; place-items:center; min-height:100vh; }
      .card { max-width:520px; margin:24px; padding:24px; border-radius:20px; background:#111c2e; border:1px solid #1c2b45; }
      h1 { margin-top:0; font-size:28px; }
      p { color:#dbe4f0; line-height:1.5; }
      .emoji { font-size:40px; margin-bottom:12px; }
    </style>
  </head>
  <body>
    <div class="card">
      <div class="emoji">${emoji}</div>
      <h1>${title}</h1>
      <p>${message}</p>
      <p>Tu peux maintenant revenir dans l'application UAPay.</p>
    </div>
  </body>
</html>`;
}

// Stripe webhooks require the raw body for signature verification.
// We register this route BEFORE express.json().
app.post('/stripe-webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const stripeKey = process.env.STRIPE_SECRET_KEY;
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    if (!stripeKey) return res.status(500).json({ error: 'Missing STRIPE_SECRET_KEY' });
    if (!webhookSecret) return res.status(500).json({ error: 'Missing STRIPE_WEBHOOK_SECRET' });

    const stripe = new Stripe(stripeKey, { apiVersion: '2024-06-20' });
    const sig = req.headers['stripe-signature'];
    let event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
    } catch (err) {
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    if (event.type !== 'checkout.session.completed') {
      return res.json({ received: true });
    }

    const session = event.data.object;
    const paid = session.payment_status === 'paid';
    if (!paid) return res.json({ received: true });

    const credit = await creditStripeSessionIfNeeded(session);
    if (!credit.ok) {
      return res.status(500).json({ error: credit.error || 'Credit failed' });
    }

    return res.json({ received: true, ...credit });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: String(e?.message || e) });
  }
});

app.use(express.json());

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: Number(process.env.RATE_LIMIT_MAX || 120),
  standardHeaders: 'draft-7',
  legacyHeaders: false,
});

app.use(apiLimiter);

const evmLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: Number(process.env.EVM_RATE_LIMIT_PER_MIN || 10),
  standardHeaders: 'draft-7',
  legacyHeaders: false,
});

const PORT = process.env.PORT || 4000;
const INITIAL_WALLET_BKN = Number(process.env.INITIAL_WALLET_BKN || 1500);

const stripeSecret = process.env.STRIPE_SECRET_KEY;
if (!stripeSecret) {
  console.warn('Missing STRIPE_SECRET_KEY (Stripe will not work).');
}
const stripe = stripeSecret ? new Stripe(stripeSecret, { apiVersion: '2024-06-20' }) : null;

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceRole = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabaseAdmin = (supabaseUrl && supabaseServiceRole)
  ? createClient(supabaseUrl, supabaseServiceRole, { auth: { persistSession: false } })
  : null;

async function ensureWalletRow(userId) {
  if (!supabaseAdmin) return { ok: false, error: 'Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY' };

  const { data: wallet, error } = await supabaseAdmin
    .from('wallets')
    .select('balance_bkn')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) {
    return { ok: false, error: error.message };
  }

  if (wallet) {
    return {
      ok: true,
      balance: Number(wallet.balance_bkn ?? INITIAL_WALLET_BKN),
      existed: true,
    };
  }

  const { error: insertError } = await supabaseAdmin
    .from('wallets')
    .upsert({
      user_id: userId,
      balance_bkn: INITIAL_WALLET_BKN,
      updated_at: new Date().toISOString(),
    });

  if (insertError) {
    return { ok: false, error: insertError.message };
  }

  return { ok: true, balance: INITIAL_WALLET_BKN, existed: false };
}

async function creditStripeSessionIfNeeded(session, sessionIdOverride = null) {
  if (!supabaseAdmin) return { ok: false, error: 'Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY' };

  const sessionId = sessionIdOverride || session.id;
  const userId = session.metadata?.user_id;
  const amountBkn = Number(session.metadata?.amount_bkn || 0);
  if (!userId || !Number.isFinite(amountBkn) || amountBkn <= 0) {
    return { ok: true, skipped: true, reason: 'missing_metadata' };
  }

  const { data: existing, error: existingError } = await supabaseAdmin
    .from('transactions')
    .select('id')
    .eq('user_id', userId)
    .eq('note', `stripe:${sessionId}`)
    .limit(1);

  if (existingError) {
    return { ok: false, error: existingError.message };
  }

  if ((existing?.length || 0) > 0) {
    return { ok: true, already_credited: true, amount_bkn: amountBkn };
  }

  const walletState = await ensureWalletRow(userId);
  if (!walletState.ok) {
    return walletState;
  }

  const current = Number(walletState.balance || 0);
  const next = current + amountBkn;

  const { error: updateErr } = await supabaseAdmin
    .from('wallets')
    .update({ balance_bkn: next, updated_at: new Date().toISOString() })
    .eq('user_id', userId);

  if (updateErr) {
    return { ok: false, error: updateErr.message };
  }

  const { error: txInsertError } = await supabaseAdmin
    .from('transactions')
    .insert({
      user_id: userId,
      type: 'BUY',
      amount_bkn: amountBkn,
      status: 'OK',
      note: `stripe:${sessionId}`,
    });

  if (txInsertError) {
    return { ok: false, error: txInsertError.message };
  }

  return {
    ok: true,
    credited: true,
    amount_bkn: amountBkn,
    new_balance: next,
    user_id: userId,
  };
}

function requireEnv(res, required, label) {
  if (!required) {
    res.status(500).json({ error: `Missing server env: ${label}` });
    return true;
  }
  return false;
}

app.get('/success', (req, res) => {
  res.status(200).type('html').send(checkoutLandingHtml({
    title: 'Paiement confirmé',
    message: 'Stripe a terminé la transaction. UAPay va vérifier le paiement et mettre à jour le wallet.',
    emoji: '✅',
  }));
});

app.get('/cancel', (req, res) => {
  res.status(200).type('html').send(checkoutLandingHtml({
    title: 'Paiement annulé',
    message: 'Le paiement a été annulé. Aucun débit ni crédit ne sera appliqué.',
    emoji: '↩️',
  }));
});

app.post('/create-checkout-session', async (req, res) => {
  try {
    if (requireEnv(res, stripe, 'STRIPE_SECRET_KEY')) return;
    const { amount_bkn, user_id, email } = req.body || {};
    const amountBkn = Number(amount_bkn);

    if (!user_id || !email || !Number.isFinite(amountBkn) || amountBkn <= 0) {
      return res.status(400).json({ error: 'Invalid payload. Need {amount_bkn, user_id, email}.' });
    }

    const amountEurCents = Math.round(amountBkn * 100);
    const baseUrl = getPublicBaseUrl(req);
    const successUrl = `${baseUrl}/success?session_id={CHECKOUT_SESSION_ID}`;
    const cancelUrl = `${baseUrl}/cancel`;

    const idempotencyMinute = Math.floor(Date.now() / 60_000);
    const idempotencyKey = `checkout-${user_id}-${amountEurCents}-${idempotencyMinute}`;

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      customer_email: email,
      line_items: [
        {
          price_data: {
            currency: 'eur',
            product_data: { name: `UAPay - Achat ${amountBkn} BKN` },
            unit_amount: amountEurCents,
          },
          quantity: 1,
        },
      ],
      success_url: process.env.STRIPE_SUCCESS_URL || successUrl,
      cancel_url: process.env.STRIPE_CANCEL_URL || cancelUrl,
      metadata: {
        user_id,
        amount_bkn: String(amountBkn),
      },
    }, { idempotencyKey });

    return res.json({ url: session.url, session_id: session.id });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: String(e?.message || e) });
  }
});

app.get('/checkout-status', async (req, res) => {
  try {
    if (requireEnv(res, stripe, 'STRIPE_SECRET_KEY')) return;

    const sessionId = String(req.query.session_id || '');
    if (!sessionId) return res.status(400).json({ error: 'Missing session_id' });

    const session = await stripe.checkout.sessions.retrieve(sessionId);
    const paid = session.payment_status === 'paid';

    if (!paid) return res.json({ paid: false });

    const creditOnStatus = parseBooleanEnv(process.env.CREDIT_ON_STATUS, true);
    if (!creditOnStatus) return res.json({ paid: true, credited: false, amount_bkn: Number(session.metadata?.amount_bkn || 0) });

    const credit = await creditStripeSessionIfNeeded(session, sessionId);
    if (!credit.ok) return res.status(500).json({ error: credit.error || 'Credit failed' });

    return res.json({ paid: true, ...credit });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: String(e?.message || e) });
  }
});

app.post('/evm/erc20/transfer', evmLimiter, async (req, res) => {
  try {
    const {
      rpc_url,
      chain,
      token_address,
      from_private_key,
      to,
      amount,
    } = req.body || {};

    if (!rpc_url || !token_address || !from_private_key || !to || amount == null) {
      return res.status(400).json({ error: 'Invalid payload. Need {rpc_url, token_address, from_private_key, to, amount}.' });
    }

    const provider = new ethers.JsonRpcProvider(String(rpc_url));
    const wallet = new ethers.Wallet(String(from_private_key), provider);

    const erc20Abi = [
      'function decimals() view returns (uint8)',
      'function transfer(address to, uint256 amount) returns (bool)',
    ];

    const token = new ethers.Contract(String(token_address), erc20Abi, wallet);
    const decimals = await token.decimals();
    const value = ethers.parseUnits(String(amount), decimals);

    const tx = await token.transfer(String(to), value);
    const wait = String(req.query.wait || '').toLowerCase() === 'true';
    if (wait) await tx.wait();

    return res.json({
      tx_hash: tx.hash,
      chain: chain || null,
      from: wallet.address,
      to,
      token: token_address,
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: String(e?.message || e) });
  }
});

app.get('/health', (_, res) => res.json({ ok: true }));

app.listen(PORT, () => {
  console.log(`UAPay Stripe backend running on :${PORT}`);
});
