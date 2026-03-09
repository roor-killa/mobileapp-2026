import '../models/transfer_response.dart';
import '../models/transaction_model.dart';
import '../models/utilisateur.dart';
import '../services/auth_service.dart';
import 'database_service.dart';

class ApiService {
  Future<TransferResponse> transfererMontant(
      double montant, Utilisateur sender, Utilisateur destinataire) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final soldeAvant = sender.soldeActuel;

    if (montant > soldeAvant) {
      await DatabaseService.instance.enregistrerTransaction(TransactionModel(
        utilisateurId: sender.id!,
        montant: montant,
        soldeAvant: soldeAvant,
        soldeApres: soldeAvant,
        statut: 'echec',
        message: 'Solde insuffisant',
        dateHeure: DateTime.now().toIso8601String(),
        type: 'envoi',
        autrePartieNom: destinataire.nom,
      ));

      return TransferResponse(
        success: false,
        montantTotal: soldeAvant,
        montantTransfere: montant,
        nouveauSolde: soldeAvant,
        message: 'Solde insuffisant',
      );
    }

    final now = DateTime.now().toIso8601String();

    // ── Débite le sender ────────────────────────────────────────────────────
    final nouveauSoldeSender = soldeAvant - montant;
    await DatabaseService.instance.mettreAJourSolde(sender.id!, nouveauSoldeSender);
    AuthService.utilisateurConnecte!.soldeActuel = nouveauSoldeSender;

    await DatabaseService.instance.enregistrerTransaction(TransactionModel(
      utilisateurId: sender.id!,
      montant: montant,
      soldeAvant: soldeAvant,
      soldeApres: nouveauSoldeSender,
      statut: 'succes',
      message: 'Envoyé à ${destinataire.nom}',
      dateHeure: now,
      type: 'envoi',
      autrePartieNom: destinataire.nom,
    ));

    // ── Crédite le destinataire (solde frais depuis la DB) ──────────────────
    final destActuel = await DatabaseService.instance.getUtilisateurById(destinataire.id!);
    final soldeDestinataire = destActuel?.soldeActuel ?? destinataire.soldeActuel;
    final nouveauSoldeDestinataire = soldeDestinataire + montant;
    await DatabaseService.instance.mettreAJourSolde(destinataire.id!, nouveauSoldeDestinataire);

    await DatabaseService.instance.enregistrerTransaction(TransactionModel(
      utilisateurId: destinataire.id!,
      montant: montant,
      soldeAvant: soldeDestinataire,
      soldeApres: nouveauSoldeDestinataire,
      statut: 'succes',
      message: 'Reçu de ${sender.nom}',
      dateHeure: now,
      type: 'reception',
      autrePartieNom: sender.nom,
    ));

    return TransferResponse(
      success: true,
      montantTotal: soldeAvant,
      montantTransfere: montant,
      nouveauSolde: nouveauSoldeSender,
      message: 'Transfert effectué avec succès',
    );
  }
}
