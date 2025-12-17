// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginTitle => 'Login to Your Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get loginLink => 'Login';

  @override
  String get onboardingTitle1 => 'Analyze Documents';

  @override
  String get onboardingDesc1 =>
      'Upload and analyze your academic documents with AI assistance';

  @override
  String get onboardingTitle2 => 'Smart Templates';

  @override
  String get onboardingDesc2 =>
      'Use pre-built templates for different document types';

  @override
  String get onboardingTitle3 => 'Get Started';

  @override
  String get onboardingDesc3 =>
      'Start organizing and improving your academic work today';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get chat => 'Chat';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get admin => 'Admin';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get documents => 'Documents';

  @override
  String get avgScore => 'Avg Score';

  @override
  String get completion => 'Completion';

  @override
  String get recentReports => 'Recent Reports';

  @override
  String get viewAll => 'View All';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get browseTemplates => 'Browse Templates';

  @override
  String get viewHistory => 'View History';

  @override
  String get settings => 'Settings';

  @override
  String get docAiChat => 'Doc AI Chat';

  @override
  String get selectContext => 'Select Context';

  @override
  String get switchContext => 'Switch Context';

  @override
  String get selectDocOrTemplate =>
      'Select a document or template to start chatting';

  @override
  String askAbout(String context) {
    return 'Ask about $context...';
  }

  @override
  String get docAiTyping => 'Doc AI is typing...';

  @override
  String get summarizeThis => 'Summarize this';

  @override
  String get explainStructure => 'Explain structure';

  @override
  String get keyPoints => 'Key points';

  @override
  String get suggestions => 'Suggestions?';

  @override
  String get documentsTab => 'Documents';

  @override
  String get templatesTab => 'Templates';

  @override
  String get noDocumentsFound => 'No documents found.';

  @override
  String get noTemplatesAvailable => 'No templates available.';

  @override
  String switchedToDocument(String filename) {
    return 'Switched context to document: $filename. What would you like to know?';
  }

  @override
  String switchedToTemplate(String name) {
    return 'Switched context to template: $name. I can explain its structure.';
  }

  @override
  String get copy => 'Copy';

  @override
  String get reply => 'Reply';

  @override
  String get messageCopied => 'Message copied';

  @override
  String get replyingToYourself => 'Replying to yourself';

  @override
  String get replyingToDocAI => 'Replying to Doc AI';

  @override
  String get historyTitle => 'Document History';

  @override
  String get filename => 'Filename';

  @override
  String get status => 'Status';

  @override
  String get analysisDate => 'Analysis Date';

  @override
  String get payment => 'Payment';

  @override
  String get actions => 'Actions';

  @override
  String get view => 'View';

  @override
  String get download => 'Download';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get analyzing => 'Analyzing';

  @override
  String get failed => 'Failed';

  @override
  String get profileRestricted => 'Profile Restricted';

  @override
  String get pleaseLogin => 'Please login to view your profile.';

  @override
  String get login => 'Login';

  @override
  String get role => 'Role';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get managePricesUsersTemplates =>
      'Manage prices, users, and templates';

  @override
  String get account => 'Account';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get security => 'Security';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get appTheme => 'App Theme';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get aboutDocAI => 'About Doc AI';

  @override
  String get logout => 'Log Out';

  @override
  String get nameField => 'Name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get phoneOptional => 'Phone (Optional)';

  @override
  String get enterPhone => 'Enter your phone number';

  @override
  String get bioOptional => 'Bio (Optional)';

  @override
  String get tellAboutYourself => 'Tell us about yourself';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String profileUpdateFailed(String error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get uploadDocumentTitle => 'Upload Document';

  @override
  String get selectTemplate => 'Select Template';

  @override
  String get chooseTemplate => 'Choose a template';

  @override
  String get selectFile => 'Select File';

  @override
  String get chooseFile => 'Choose a file to upload';

  @override
  String get upload => 'Upload';

  @override
  String get uploadSuccess => 'Document uploaded successfully!';

  @override
  String get uploadError => 'Upload failed';

  @override
  String get analysisResults => 'Analysis Results';

  @override
  String get documentAnalysis => 'Document Analysis';

  @override
  String get analyzingUnderscore => 'Analyzing...';

  @override
  String get analysisComplete => 'Analysis Complete';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get general => 'General';

  @override
  String get users => 'Users';

  @override
  String get templates => 'Templates';

  @override
  String get systemConfig => 'System Configuration';

  @override
  String get printPrice => 'Print Price';

  @override
  String get dueDate => 'Due Date';

  @override
  String get updateConfig => 'Update Configuration';

  @override
  String get userManagement => 'User Management';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get addUser => 'Add User';

  @override
  String get roleUnderscore => 'Role';

  @override
  String get template => 'Template';

  @override
  String get addTemplate => 'Add Template';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get deleteTemplate => 'Delete Template';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get student => 'Student';

  @override
  String get adminRole => 'Admin';
}
