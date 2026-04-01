// Supabase Edge Function: stripe-webhook
// Handles Stripe webhook events (TEST MODE) and credits the user's wallet.
//
// Deploy:
//   supabase functions deploy stripe-webhook
//
// Required env vars (Supabase Dashboard -> Edge Functions -> Secrets):
//   STRIPE_SECRET_KEY
//   STRIPE_WEBHOOK_SECRET
//   SUPABASE_SERVICE_ROLE_KEY
//
// This function listens for: checkout.session.completed
// It increments wallets.balance_bkn and inserts a BUY transaction with status OK.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.25.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.1";

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method !== "POST") return jsonResponse({ error: "Method not allowed" }, 405);

  const stripeKey = Deno.env.get("STRIPE_SECRET_KEY");
  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");

  if (!stripeKey || !webhookSecret || !serviceRoleKey || !supabaseUrl) {
    return jsonResponse({ error: "Missing server env vars" }, 500);
  }

  const stripe = new Stripe(stripeKey, { apiVersion: "2023-10-16" });

  const sig = req.headers.get("Stripe-Signature");
  if (!sig) return jsonResponse({ error: "Missing Stripe-Signature" }, 400);

  const rawBody = new Uint8Array(await req.arrayBuffer());

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(rawBody, sig, webhookSecret);
  } catch (err) {
    return jsonResponse({ error: `Webhook signature verification failed: ${String(err)}` }, 400);
  }

  // Service role client to bypass RLS
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  try {
    if (event.type === "checkout.session.completed") {
      const session = event.data.object as Stripe.Checkout.Session;

      const userId = session.metadata?.supabase_user_id;
      const amountBknStr = session.metadata?.amount_bkn;

      const amountBkn = Number(amountBknStr ?? 0);

      if (!userId || !Number.isFinite(amountBkn) || amountBkn <= 0) {
        return jsonResponse({ ok: false, error: "Missing metadata" }, 400);
      }

      // 1) Read current balance
      const { data: wallet, error: wErr } = await supabase
        .from("wallets")
        .select("balance_bkn")
        .eq("user_id", userId)
        .maybeSingle();

      if (wErr) throw wErr;

      const current = Number(wallet?.balance_bkn ?? 0);
      const next = current + amountBkn;

      // 2) Update wallet
      const { error: upErr } = await supabase
        .from("wallets")
        .update({ balance_bkn: next, updated_at: new Date().toISOString() })
        .eq("user_id", userId);

      if (upErr) throw upErr;

      // 3) Insert transaction
      const { error: txErr } = await supabase.from("transactions").insert({
        user_id: userId,
        type: "BUY",
        amount_bkn: amountBkn,
        counterparty: null,
        status: "OK",
      });

      if (txErr) throw txErr;

      return jsonResponse({ ok: true });
    }

    // Ignore other events for this academic project
    return jsonResponse({ ok: true, ignored: true, type: event.type });
  } catch (e) {
    return jsonResponse({ ok: false, error: String(e) }, 500);
  }
});
