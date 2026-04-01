import { createBrowserRouter } from "react-router";
import Layout from "./components/Layout";
import ProtectedRoute from "./components/ProtectedRoute";
import Dashboard from "./components/Dashboard";
import Transfers from "./components/Transfers";
import Crypto from "./components/Crypto";
import Investments from "./components/Investments";
import Cards from "./components/Cards";
import Analytics from "./components/Analytics";
import Security from "./components/Security";
import Profile from "./components/Profile";
import Invoicing from "./components/Invoicing";
import Login from "./components/Login";
import SignUp from "./components/SignUp";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/signup",
    Component: SignUp,
  },
  {
    Component: ProtectedRoute,
    children: [
      {
        path: "/",
        Component: Layout,
        children: [
          { index: true, Component: Dashboard },
          { path: "transfers", Component: Transfers },
          { path: "crypto", Component: Crypto },
          { path: "investments", Component: Investments },
          { path: "cards", Component: Cards },
          { path: "analytics", Component: Analytics },
          { path: "security", Component: Security },
          { path: "profile", Component: Profile },
          { path: "invoices", Component: Invoicing },
        ],
      },
    ],
  },
]);
