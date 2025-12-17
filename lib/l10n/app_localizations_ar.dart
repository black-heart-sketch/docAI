// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get loginTitle => 'تسجيل الدخول إلى حسابك';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get noAccount => 'لا تملك حساباً؟';

  @override
  String get signUpLink => 'إنشاء حساب';

  @override
  String get signUpTitle => 'إنشاء حساب';

  @override
  String get nameLabel => 'الاسم الكامل';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get loginLink => 'تسجيل الدخول';

  @override
  String get onboardingTitle1 => 'تحليل المستندات';

  @override
  String get onboardingDesc1 =>
      'قم بتحميل وتحليل مستنداتك الأكاديمية بمساعدة الذكاء الاصطناعي';

  @override
  String get onboardingTitle2 => 'قوالب ذكية';

  @override
  String get onboardingDesc2 =>
      'استخدم القوالب الجاهزة لأنواع المستندات المختلفة';

  @override
  String get onboardingTitle3 => 'ابدأ الآن';

  @override
  String get onboardingDesc3 => 'ابدأ في تنظيم وتحسين عملك الأكاديمي اليوم';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get skip => 'تخطي';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get home => 'الرئيسية';

  @override
  String get chat => 'المحادثة';

  @override
  String get history => 'السجل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get admin => 'المدير';

  @override
  String welcomeUser(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get quickStats => 'إحصائيات سريعة';

  @override
  String get documents => 'المستندات';

  @override
  String get avgScore => 'المعدل';

  @override
  String get completion => 'الإنجاز';

  @override
  String get recentReports => 'التقارير الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get uploadDocument => 'تحميل مستند';

  @override
  String get browseTemplates => 'استعراض القوالب';

  @override
  String get viewHistory => 'عرض السجل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get docAiChat => 'محادثة Doc AI';

  @override
  String get selectContext => 'اختر السياق';

  @override
  String get switchContext => 'تغيير السياق';

  @override
  String get selectDocOrTemplate => 'اختر مستنداً أو قالباً لبدء المحادثة';

  @override
  String askAbout(String context) {
    return 'اسأل عن $context...';
  }

  @override
  String get docAiTyping => 'Doc AI يكتب...';

  @override
  String get summarizeThis => 'تلخيص هذا';

  @override
  String get explainStructure => 'شرح الهيكل';

  @override
  String get keyPoints => 'النقاط الرئيسية';

  @override
  String get suggestions => 'اقتراحات؟';

  @override
  String get documentsTab => 'المستندات';

  @override
  String get templatesTab => 'القوالب';

  @override
  String get noDocumentsFound => 'لا توجد مستندات.';

  @override
  String get noTemplatesAvailable => 'لا توجد قوالب متاحة.';

  @override
  String switchedToDocument(String filename) {
    return 'تم التبديل إلى المستند: $filename. ماذا تريد أن تعرف؟';
  }

  @override
  String switchedToTemplate(String name) {
    return 'تم التبديل إلى القالب: $name. يمكنني شرح هيكله.';
  }

  @override
  String get copy => 'نسخ';

  @override
  String get reply => 'رد';

  @override
  String get messageCopied => 'تم نسخ الرسالة';

  @override
  String get replyingToYourself => 'الرد على نفسك';

  @override
  String get replyingToDocAI => 'الرد على Doc AI';

  @override
  String get historyTitle => 'سجل المستندات';

  @override
  String get filename => 'اسم الملف';

  @override
  String get status => 'الحالة';

  @override
  String get analysisDate => 'تاريخ التحليل';

  @override
  String get payment => 'الدفع';

  @override
  String get actions => 'الإجراءات';

  @override
  String get view => 'عرض';

  @override
  String get download => 'تحميل';

  @override
  String get paid => 'مدفوع';

  @override
  String get unpaid => 'غير مدفوع';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get completed => 'مكتمل';

  @override
  String get analyzing => 'جاري التحليل';

  @override
  String get failed => 'فشل';

  @override
  String get profileRestricted => 'الملف الشخصي محظور';

  @override
  String get pleaseLogin => 'الرجاء تسجيل الدخول لعرض ملفك الشخصي.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get role => 'الدور';

  @override
  String get adminDashboard => 'لوحة تحكم المدير';

  @override
  String get managePricesUsersTemplates => 'إدارة الأسعار والمستخدمين والقوالب';

  @override
  String get account => 'الحساب';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get security => 'الأمان';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get appTheme => 'مظهر التطبيق';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get aboutDocAI => 'حول Doc AI';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get nameField => 'الاسم';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get invalidEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get phoneOptional => 'الهاتف (اختياري)';

  @override
  String get enterPhone => 'أدخل رقم هاتفك';

  @override
  String get bioOptional => 'السيرة الذاتية (اختياري)';

  @override
  String get tellAboutYourself => 'أخبرنا عن نفسك';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String profileUpdateFailed(String error) {
    return 'فشل تحديث الملف الشخصي: $error';
  }

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get uploadDocumentTitle => 'تحميل مستند';

  @override
  String get selectTemplate => 'اختر قالباً';

  @override
  String get chooseTemplate => 'اختر قالباً';

  @override
  String get selectFile => 'اختر ملفاً';

  @override
  String get chooseFile => 'اختر ملفاً للتحميل';

  @override
  String get upload => 'تحميل';

  @override
  String get uploadSuccess => 'تم تحميل المستند بنجاح!';

  @override
  String get uploadError => 'فشل التحميل';

  @override
  String get analysisResults => 'نتائج التحليل';

  @override
  String get documentAnalysis => 'تحليل المستند';

  @override
  String get analyzingUnderscore => 'جاري التحليل...';

  @override
  String get analysisComplete => 'اكتمل التحليل';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get adminPanel => 'لوحة الإدارة';

  @override
  String get general => 'عام';

  @override
  String get users => 'المستخدمون';

  @override
  String get templates => 'القوالب';

  @override
  String get systemConfig => 'إعدادات النظام';

  @override
  String get printPrice => 'سعر الطباعة';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get updateConfig => 'تحديث الإعدادات';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get totalUsers => 'إجمالي المستخدمين';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get roleUnderscore => 'الدور';

  @override
  String get template => 'قالب';

  @override
  String get addTemplate => 'إضافة قالب';

  @override
  String get editTemplate => 'تعديل القالب';

  @override
  String get deleteTemplate => 'حذف القالب';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get student => 'طالب';

  @override
  String get adminRole => 'مدير';
}
