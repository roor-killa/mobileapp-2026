import type { OdooInvoice } from "./invoicingApi";

const STORAGE_KEY = "secondapp-invoicing-drafts-v1";

function readRaw(): OdooInvoice[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw) as unknown;
    if (!Array.isArray(parsed)) return [];
    return parsed as OdooInvoice[];
  } catch {
    return [];
  }
}

function writeRaw(list: OdooInvoice[]) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
}

/** Brouillons créés ou modifiés côté client (json-server ne persiste pas en écriture). */
export function loadPersistedDrafts(): OdooInvoice[] {
  return readRaw();
}

export function savePersistedDrafts(list: OdooInvoice[]) {
  writeRaw(list);
}

export function upsertPersistedDraft(invoice: OdooInvoice) {
  const list = readRaw();
  const i = list.findIndex((x) => x.id === invoice.id);
  if (i >= 0) list[i] = invoice;
  else list.push(invoice);
  writeRaw(list);
}

export function removePersistedDraft(id: number) {
  writeRaw(readRaw().filter((x) => x.id !== id));
}

export function mergeApiWithPersisted(
  fromApi: OdooInvoice[],
  persisted: OdooInvoice[],
): OdooInvoice[] {
  const map = new Map<number, OdooInvoice>();
  for (const inv of fromApi) {
    map.set(inv.id, inv);
  }
  for (const p of persisted) {
    map.set(p.id, p);
  }
  return Array.from(map.values()).sort((a, b) => b.id - a.id);
}
