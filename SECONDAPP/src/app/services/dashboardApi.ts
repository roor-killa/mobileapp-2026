export type DashboardBalancePoint = { month: string; value: number };

export type DashboardTransaction = {
  id: number;
  name: string;
  category: string;
  amount: number;
  icon: string;
  color: string;
  time: string;
};

export type DashboardInsight = {
  title: string;
  value: string;
  description: string;
  trend: "up" | "warning";
};

export type DashboardResponse = {
  balanceData: DashboardBalancePoint[];
  transactions: DashboardTransaction[];
  insights: DashboardInsight[];
};

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3001";

export async function getDashboardData(): Promise<DashboardResponse | null> {
  try {
    const res = await fetch(`${API_BASE_URL}/dashboard`);
    if (!res.ok) {
      return null;
    }

    const payload = (await res.json()) as DashboardResponse;
    return payload;
  } catch {
    return null;
  }
}
