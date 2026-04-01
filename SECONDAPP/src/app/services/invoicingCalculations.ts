import type { OdooInvoice, OdooInvoiceLine } from "./invoicingApi";

export function lineSubtotal(quantity: number, priceUnit: number): number {
  return Math.round(quantity * priceUnit * 100) / 100;
}

export function lineTaxAmount(subtotal: number, taxPercent: number): number {
  return Math.round(subtotal * (taxPercent / 100) * 100) / 100;
}

export function normalizeLine(line: OdooInvoiceLine): OdooInvoiceLine {
  const sub = lineSubtotal(line.quantity, line.price_unit);
  return {
    ...line,
    price_subtotal: sub,
  };
}

export function recalcInvoiceTotals(lines: OdooInvoiceLine[]): {
  amount_untaxed: number;
  amount_tax: number;
  amount_total: number;
} {
  let untaxed = 0;
  let tax = 0;
  for (const raw of lines) {
    const line = normalizeLine(raw);
    untaxed += line.price_subtotal;
    tax += lineTaxAmount(line.price_subtotal, line.tax_percent);
  }
  untaxed = Math.round(untaxed * 100) / 100;
  tax = Math.round(tax * 100) / 100;
  const total = Math.round((untaxed + tax) * 100) / 100;
  return { amount_untaxed: untaxed, amount_tax: tax, amount_total: total };
}

export function recalcInvoice(inv: OdooInvoice): OdooInvoice {
  const normalizedLines = inv.invoice_line_ids.map((l) => normalizeLine(l));
  const t = recalcInvoiceTotals(normalizedLines);
  return {
    ...inv,
    invoice_line_ids: normalizedLines,
    ...t,
  };
}

let lineIdSeq = 0;
export function nextLineId(): number {
  lineIdSeq -= 1;
  return lineIdSeq;
}

export function createEmptyDraftInvoice(partnerId: number): OdooInvoice {
  const today = new Date().toISOString().slice(0, 10);
  const due = new Date();
  due.setMonth(due.getMonth() + 1);
  const id = -Date.now();
  return recalcInvoice({
    id,
    name: `BROUILLON/${new Date().getFullYear()}/${Math.abs(id) % 100000}`,
    move_type: "out_invoice",
    partner_id: partnerId,
    invoice_date: today,
    invoice_date_due: due.toISOString().slice(0, 10),
    state: "draft",
    payment_state: "not_paid",
    currency: "EUR",
    amount_untaxed: 0,
    amount_tax: 0,
    amount_total: 0,
    narration: "",
    invoice_line_ids: [
      {
        id: nextLineId(),
        name: "",
        quantity: 1,
        price_unit: 0,
        tax_percent: 20,
        price_subtotal: 0,
      },
    ],
  });
}
