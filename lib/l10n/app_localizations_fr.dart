// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get loginTitle => 'Connectez-vous à votre compte';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Connexion';

  @override
  String get noAccount => 'Vous n\'avez pas de compte?';

  @override
  String get signUpLink => 'S\'inscrire';

  @override
  String get signUpTitle => 'Créer un compte';

  @override
  String get nameLabel => 'Nom complet';

  @override
  String get signUpButton => 'S\'inscrire';

  @override
  String get haveAccount => 'Vous avez déjà un compte?';

  @override
  String get loginLink => 'Connexion';

  @override
  String get onboardingTitle1 => 'Analyser des documents';

  @override
  String get onboardingDesc1 =>
      'Téléchargez et analysez vos documents académiques avec l\'assistance IA';

  @override
  String get onboardingTitle2 => 'Modèles intelligents';

  @override
  String get onboardingDesc2 =>
      'Utilisez des modèles pré-construits pour différents types de documents';

  @override
  String get onboardingTitle3 => 'Commencer';

  @override
  String get onboardingDesc3 =>
      'Commencez à organiser et améliorer votre travail académique aujourd\'hui';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get home => 'Accueil';

  @override
  String get chat => 'Discussion';

  @override
  String get history => 'Historique';

  @override
  String get profile => 'Profil';

  @override
  String get admin => 'Administrateur';

  @override
  String welcomeUser(String name) {
    return 'Bienvenue, $name';
  }

  @override
  String get quickStats => 'Statistiques rapides';

  @override
  String get documents => 'Documents';

  @override
  String get avgScore => 'Score moyen';

  @override
  String get completion => 'Achèvement';

  @override
  String get recentReports => 'Rapports récents';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get uploadDocument => 'Télécharger un document';

  @override
  String get browseTemplates => 'Parcourir les modèles';

  @override
  String get viewHistory => 'Voir l\'historique';

  @override
  String get settings => 'Paramètres';

  @override
  String get docAiChat => 'Discussion Doc AI';

  @override
  String get selectContext => 'Sélectionner le contexte';

  @override
  String get switchContext => 'Changer de contexte';

  @override
  String get selectDocOrTemplate =>
      'Sélectionnez un document ou un modèle pour commencer à discuter';

  @override
  String askAbout(String context) {
    return 'Poser une question sur $context...';
  }

  @override
  String get docAiTyping => 'Doc AI est en train d\'écrire...';

  @override
  String get summarizeThis => 'Résumer ceci';

  @override
  String get explainStructure => 'Expliquer la structure';

  @override
  String get keyPoints => 'Points clés';

  @override
  String get suggestions => 'Suggestions?';

  @override
  String get documentsTab => 'Documents';

  @override
  String get templatesTab => 'Modèles';

  @override
  String get noDocumentsFound => 'Aucun document trouvé.';

  @override
  String get noTemplatesAvailable => 'Aucun modèle disponible.';

  @override
  String switchedToDocument(String filename) {
    return 'Contexte changé vers le document: $filename. Que souhaitez-vous savoir?';
  }

  @override
  String switchedToTemplate(String name) {
    return 'Contexte changé vers le modèle: $name. Je peux expliquer sa structure.';
  }

  @override
  String get copy => 'Copier';

  @override
  String get reply => 'Répondre';

  @override
  String get messageCopied => 'Message copié';

  @override
  String get replyingToYourself => 'Répondre à vous-même';

  @override
  String get replyingToDocAI => 'Répondre à Doc AI';

  @override
  String get historyTitle => 'Historique des documents';

  @override
  String get filename => 'Nom du fichier';

  @override
  String get status => 'Statut';

  @override
  String get analysisDate => 'Date d\'analyse';

  @override
  String get payment => 'Paiement';

  @override
  String get actions => 'Actions';

  @override
  String get view => 'Voir';

  @override
  String get download => 'Télécharger';

  @override
  String get paid => 'Payé';

  @override
  String get unpaid => 'Non payé';

  @override
  String get pending => 'En attente';

  @override
  String get completed => 'Terminé';

  @override
  String get analyzing => 'Analyse en cours';

  @override
  String get failed => 'Échoué';

  @override
  String get profileRestricted => 'Profil restreint';

  @override
  String get pleaseLogin => 'Veuillez vous connecter pour voir votre profil.';

  @override
  String get login => 'Connexion';

  @override
  String get role => 'Rôle';

  @override
  String get adminDashboard => 'Tableau de bord administrateur';

  @override
  String get managePricesUsersTemplates =>
      'Gérer les prix, utilisateurs et modèles';

  @override
  String get account => 'Compte';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get security => 'Sécurité';

  @override
  String get paymentMethods => 'Méthodes de paiement';

  @override
  String get preferences => 'Préférences';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get appTheme => 'Thème de l\'application';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get aboutDocAI => 'À propos de Doc AI';

  @override
  String get logout => 'Déconnexion';

  @override
  String get nameField => 'Nom';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get email => 'E-mail';

  @override
  String get enterEmail => 'Entrez votre e-mail';

  @override
  String get emailRequired => 'L\'e-mail est requis';

  @override
  String get invalidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get phoneOptional => 'Téléphone (Optionnel)';

  @override
  String get enterPhone => 'Entrez votre numéro de téléphone';

  @override
  String get bioOptional => 'Bio (Optionnel)';

  @override
  String get tellAboutYourself => 'Parlez-nous de vous';

  @override
  String get saveChanges => 'Sauvegarder les modifications';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String profileUpdateFailed(String error) {
    return 'Échec de la mise à jour du profil: $error';
  }

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get uploadDocumentTitle => 'Télécharger un document';

  @override
  String get selectTemplate => 'Sélectionner un modèle';

  @override
  String get chooseTemplate => 'Choisir un modèle';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String get chooseFile => 'Choisir un fichier à télécharger';

  @override
  String get upload => 'Télécharger';

  @override
  String get uploadSuccess => 'Document téléchargé avec succès!';

  @override
  String get uploadError => 'Échec du téléchargement';

  @override
  String get analysisResults => 'Résultats de l\'analyse';

  @override
  String get documentAnalysis => 'Analyse du document';

  @override
  String get analyzingUnderscore => 'Analyse en cours...';

  @override
  String get analysisComplete => 'Analyse terminée';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get adminPanel => 'Panneau d\'administration';

  @override
  String get general => 'Général';

  @override
  String get users => 'Utilisateurs';

  @override
  String get templates => 'Modèles';

  @override
  String get systemConfig => 'Configuration du système';

  @override
  String get printPrice => 'Prix d\'impression';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get updateConfig => 'Mettre à jour la configuration';

  @override
  String get userManagement => 'Gestion des utilisateurs';

  @override
  String get totalUsers => 'Total des utilisateurs';

  @override
  String get addUser => 'Ajouter un utilisateur';

  @override
  String get roleUnderscore => 'Rôle';

  @override
  String get template => 'Modèle';

  @override
  String get addTemplate => 'Ajouter un modèle';

  @override
  String get editTemplate => 'Modifier le modèle';

  @override
  String get deleteTemplate => 'Supprimer le modèle';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get student => 'Étudiant';

  @override
  String get adminRole => 'Administrateur';
}
