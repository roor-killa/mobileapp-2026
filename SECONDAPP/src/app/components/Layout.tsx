import { Outlet, useLocation, Link } from "react-router";
import { Home, ArrowLeftRight, Bitcoin, TrendingUp, CreditCard, PieChart, Shield, User, Receipt } from "lucide-react";
import FuturisticBackground from "./effects/FuturisticBackground";
import LEDIndicator from "./effects/LEDIndicator";
import { useTheme } from "../contexts/ThemeContext";

export default function Layout() {
  const location = useLocation();
  const { theme } = useTheme();

  const navItems = [
    { path: "/", icon: Home, label: "Home" },
    { path: "/transfers", icon: ArrowLeftRight, label: "Transfer" },
    { path: "/crypto", icon: Bitcoin, label: "Crypto" },
    { path: "/investments", icon: TrendingUp, label: "Invest" },
  ];

  const isActive = (path: string) => {
    if (path === "/") {
      return location.pathname === "/";
    }
    return location.pathname.startsWith(path);
  };

  return (
    <div className={`min-h-screen bg-gradient-to-br ${theme.gradient} text-white overflow-hidden`}>
      {/* Futuristic Background Effects */}
      <FuturisticBackground />
      
      {/* Mobile Container */}
      <div className="max-w-md mx-auto min-h-screen flex flex-col relative z-10">
        {/* Content Area */}
        <div className="flex-1 pb-24 overflow-auto">
          <Outlet />
        </div>

        {/* Bottom Navigation */}
        <nav className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-white/20 backdrop-blur-2xl border-t border-white/30 shadow-[0_-4px_30px_rgba(255,255,255,0.2)]">
          <div className="flex justify-around items-center px-2 py-2">
            {navItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className="flex-1 flex flex-col items-center gap-1.5 relative group"
                >
                  <div className={`p-3 rounded-2xl transition-all duration-300 relative ${ 
                    active 
                      ? "bg-white scale-110 shadow-xl" 
                      : "bg-white/10 group-hover:bg-white/20"
                  }`}>
                    <Icon className={`w-6 h-6 transition-colors ${active ? "text-purple-600" : "text-white group-hover:text-white"}`} />
                    {active && (
                      <div className="absolute -top-1 -right-1">
                        <LEDIndicator color="blue" size="sm" />
                      </div>
                    )}
                  </div>
                  <span className={`text-xs font-medium transition-colors ${active ? "text-white font-bold" : "text-white/70 group-hover:text-white"}`}>
                    {item.label}
                  </span>
                </Link>
              );
            })}
          </div>
        </nav>

        {/* Floating Action Menu */}
        <div className="fixed top-6 right-6 flex flex-wrap justify-end gap-2 z-10 max-w-[min(100%,28rem)]">
          <Link
            to="/invoices"
            className={`p-3 rounded-2xl backdrop-blur-xl transition-all hover:scale-110 shadow-lg ${
              isActive("/invoices")
                ? "bg-white shadow-2xl"
                : "bg-white/20 border-2 border-white/40 hover:border-white/60 hover:bg-white/30"
            }`}
            title="Facturation (Odoo)"
          >
            <Receipt className={`w-5 h-5 ${isActive("/invoices") ? "text-amber-500" : "text-white"}`} />
          </Link>
          <Link
            to="/analytics"
            className={`p-3 rounded-2xl backdrop-blur-xl transition-all hover:scale-110 shadow-lg ${
              isActive("/analytics")
                ? "bg-white shadow-2xl"
                : "bg-white/20 border-2 border-white/40 hover:border-white/60 hover:bg-white/30"
            }`}
          >
            <PieChart className={`w-5 h-5 ${isActive("/analytics") ? "text-emerald-500" : "text-white"}`} />
          </Link>
          <Link
            to="/cards"
            className={`p-3 rounded-2xl backdrop-blur-xl transition-all hover:scale-110 shadow-lg ${
              isActive("/cards")
                ? "bg-white shadow-2xl"
                : "bg-white/20 border-2 border-white/40 hover:border-white/60 hover:bg-white/30"
            }`}
          >
            <CreditCard className={`w-5 h-5 ${isActive("/cards") ? "text-purple-500" : "text-white"}`} />
          </Link>
          <Link
            to="/security"
            className={`p-3 rounded-2xl backdrop-blur-xl transition-all hover:scale-110 shadow-lg ${
              isActive("/security")
                ? "bg-white shadow-2xl"
                : "bg-white/20 border-2 border-white/40 hover:border-white/60 hover:bg-white/30"
            }`}
          >
            <Shield className={`w-5 h-5 ${isActive("/security") ? "text-blue-500" : "text-white"}`} />
          </Link>
          <Link
            to="/profile"
            className={`p-3 rounded-2xl backdrop-blur-xl transition-all hover:scale-110 shadow-lg ${
              isActive("/profile")
                ? "bg-white shadow-2xl"
                : "bg-white/20 border-2 border-white/40 hover:border-white/60 hover:bg-white/30"
            }`}
          >
            <User className={`w-5 h-5 ${isActive("/profile") ? "text-orange-500" : "text-white"}`} />
          </Link>
        </div>
      </div>
    </div>
  );
}