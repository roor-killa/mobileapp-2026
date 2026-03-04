import '../models/transfer_response.dart';
import '../models/transaction_model.dart';
import '../models/utilisateur.dart';
import '../services/auth_service.dart';
import 'database_service.dart';

class ApiService {
  /// Simule un transfert et persiste le résultat en base de données
  Future<TransferResponse> transfererMontant(double montant, Utilisateur user) async {
    // Simule un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    final soldeAvant = user.soldeActuel;

    if (montant > soldeAvant) {
      // Enregistre la tentative échouée
      await DatabaseService.instance.enregistrerTransaction(TransactionModel(
        utilisateurId: user.id!,
        montant: montant,
        soldeAvant: soldeAvant,
        soldeApres: soldeAvant,
        statut: 'echec',
        message: 'Solde insuffisant',
        dateHeure: DateTime.now().toIso8601String(),
      ));

      return TransferResponse(
        success: false,
        montantTotal: soldeAvant,
        montantTransfere: montant,
        nouveauSolde: soldeAvant,
        message: 'Solde insuffisant',
      );
    }

    final nouveauSolde = soldeAvant - montant;

    // Persiste le nouveau solde
    await DatabaseService.instance.mettreAJourSolde(user.id!, nouveauSolde);
    AuthService.utilisateurConnecte!.soldeActuel = nouveauSolde;

    // Enregistre la transaction réussie
    await DatabaseService.instance.enregistrerTransaction(TransactionModel(
      utilisateurId: user.id!,
      montant: montant,
      soldeAvant: soldeAvant,
      soldeApres: nouveauSolde,
      statut: 'succes',
      message: 'Transfert effectué avec succès',
      dateHeure: DateTime.now().toIso8601String(),
    ));

    return TransferResponse(
      success: true,
      montantTotal: soldeAvant,
      montantTransfere: montant,
      nouveauSolde: nouveauSolde,
      message: 'Transfert effectué avec succès',
    );
  }
}
