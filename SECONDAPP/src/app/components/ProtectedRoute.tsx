import { Navigate, Outlet } from "react-router";
import { useAuth } from "../contexts/AuthContext";

/**
 * Redirige vers /login tant que l’utilisateur n’a pas validé une connexion
 * dans cette session (mémoire uniquement — pas de persistance).
 */
export default function ProtectedRoute() {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}
