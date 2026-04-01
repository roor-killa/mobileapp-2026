// Supabase Edge Function: create-checkout-session
// Creates a Stripe Checkout Session (TEST MODE) for buying BKN.
// The authenticated Supabase user is charged in EUR (1 BKN = 1€).
//
// Deploy:
//   supabase functions deploy create-checkout-session
//
// Required env vars (Supabase Dashboard -> Edge Functions -> Secrets):
//   STRIPE_SECRET_KEY
//   CHECKOUT_SUCCESS_URL   (e.g., https://example.com/success)
//   CHECKOUT_CANCEL_URL    (e.g., https://example.com/cancel)

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
  if (!stripeKey) return jsonResponse({ error: "Missing STRIPE_SECRET_KEY" }, 500);

  // Create supabase client using the user's JWT (Authorization header)
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const authHeader = req.headers.get("Authorization") ?? "";

  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: { user }, error: userErr } = await supabase.auth.getUser();
  if (userErr || !user) return jsonResponse({ error: "Unauthorized" }, 401);

  const payload = await req.json().catch(() => ({}));
  const amountBkn = Number(payload?.amount_bkn ?? payload?.amountBkn ?? 0);

  if (!Number.isFinite(amountBkn) || amountBkn <= 0) {
    return jsonResponse({ error: "Invalid amount" }, 400);
  }

  // 1 BKN = 1€ -> Stripe needs cents
  const amountCents = Math.round(amountBkn * 100);

  const stripe = new Stripe(stripeKey, { apiVersion: "2023-10-16" });

  const successUrl = Deno.env.get("CHECKOUT_SUCCESS_URL") ?? "https://example.com/success";
  const cancelUrl = Deno.env.get("CHECKOUT_CANCEL_URL") ?? "https://example.com/cancel";

  try {
    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      success_url: successUrl,
      cancel_url: cancelUrl,
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "eur",
            unit_amount: amountCents,
            product_data: {
              name: `UAPay — Achat ${amountBkn} BKN`,
              description: "1 BKN = 1€ (test mode)",
            },
          },
          quantity: 1,
        },
      ],
      // Important: store info for webhook
      metadata: {
        supabase_user_id: user.id,
        amount_bkn: String(amountBkn),
      },
    });

    return jsonResponse({
      ok: true,
      checkout_url: session.url,
      session_id: session.id,
    });
  } catch (e) {
    return jsonResponse({ ok: false, error: String(e) }, 500);
  }
});
