// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginTitle => 'Inicia sesión en tu cuenta';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get signUpLink => 'Regístrate';

  @override
  String get signUpTitle => 'Crear cuenta';

  @override
  String get nameLabel => 'Nombre completo';

  @override
  String get signUpButton => 'Registrarse';

  @override
  String get haveAccount => '¿Ya tienes una cuenta?';

  @override
  String get loginLink => 'Iniciar sesión';

  @override
  String get onboardingTitle1 => 'Analizar documentos';

  @override
  String get onboardingDesc1 =>
      'Sube y analiza tus documentos académicos con asistencia IA';

  @override
  String get onboardingTitle2 => 'Plantillas inteligentes';

  @override
  String get onboardingDesc2 =>
      'Usa plantillas predefinidas para diferentes tipos de documentos';

  @override
  String get onboardingTitle3 => 'Comenzar';

  @override
  String get onboardingDesc3 =>
      'Comienza a organizar y mejorar tu trabajo académico hoy';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get skip => 'Saltar';

  @override
  String get dashboard => 'Panel';

  @override
  String get home => 'Inicio';

  @override
  String get chat => 'Chat';

  @override
  String get history => 'Historial';

  @override
  String get profile => 'Perfil';

  @override
  String get admin => 'Admin';

  @override
  String welcomeUser(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String get quickStats => 'Estadísticas rápidas';

  @override
  String get documents => 'Documentos';

  @override
  String get avgScore => 'Puntaje prom';

  @override
  String get completion => 'Completado';

  @override
  String get recentReports => 'Informes recientes';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get uploadDocument => 'Subir documento';

  @override
  String get browseTemplates => 'Explorar plantillas';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get settings => 'Configuración';

  @override
  String get docAiChat => 'Chat Doc AI';

  @override
  String get selectContext => 'Seleccionar contexto';

  @override
  String get switchContext => 'Cambiar contexto';

  @override
  String get selectDocOrTemplate =>
      'Selecciona un documento o plantilla para comenzar a chatear';

  @override
  String askAbout(String context) {
    return 'Preguntar sobre $context...';
  }

  @override
  String get docAiTyping => 'Doc AI está escribiendo...';

  @override
  String get summarizeThis => 'Resumir esto';

  @override
  String get explainStructure => 'Explicar estructura';

  @override
  String get keyPoints => 'Puntos clave';

  @override
  String get suggestions => '¿Sugerencias?';

  @override
  String get documentsTab => 'Documentos';

  @override
  String get templatesTab => 'Plantillas';

  @override
  String get noDocumentsFound => 'No se encontraron documentos.';

  @override
  String get noTemplatesAvailable => 'No hay plantillas disponibles.';

  @override
  String switchedToDocument(String filename) {
    return 'Contexto cambiado al documento: $filename. ¿Qué te gustaría saber?';
  }

  @override
  String switchedToTemplate(String name) {
    return 'Contexto cambiado a la plantilla: $name. Puedo explicar su estructura.';
  }

  @override
  String get copy => 'Copiar';

  @override
  String get reply => 'Responder';

  @override
  String get messageCopied => 'Mensaje copiado';

  @override
  String get replyingToYourself => 'Respondiéndote a ti mismo';

  @override
  String get replyingToDocAI => 'Respondiendo a Doc AI';

  @override
  String get historyTitle => 'Historial de documentos';

  @override
  String get filename => 'Nombre de archivo';

  @override
  String get status => 'Estado';

  @override
  String get analysisDate => 'Fecha de análisis';

  @override
  String get payment => 'Pago';

  @override
  String get actions => 'Acciones';

  @override
  String get view => 'Ver';

  @override
  String get download => 'Descargar';

  @override
  String get paid => 'Pagado';

  @override
  String get unpaid => 'No pagado';

  @override
  String get pending => 'Pendiente';

  @override
  String get completed => 'Completado';

  @override
  String get analyzing => 'Analizando';

  @override
  String get failed => 'Fallido';

  @override
  String get profileRestricted => 'Perfil restringido';

  @override
  String get pleaseLogin => 'Por favor, inicia sesión para ver tu perfil.';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get role => 'Rol';

  @override
  String get adminDashboard => 'Panel de administración';

  @override
  String get managePricesUsersTemplates =>
      'Gestionar precios, usuarios y plantillas';

  @override
  String get account => 'Cuenta';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get security => 'Seguridad';

  @override
  String get paymentMethods => 'Métodos de pago';

  @override
  String get preferences => 'Preferencias';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get appTheme => 'Tema de la aplicación';

  @override
  String get support => 'Soporte';

  @override
  String get helpCenter => 'Centro de ayuda';

  @override
  String get aboutDocAI => 'Acerca de Doc AI';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get nameField => 'Nombre';

  @override
  String get enterFullName => 'Ingresa tu nombre completo';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get email => 'Correo electrónico';

  @override
  String get enterEmail => 'Ingresa tu correo electrónico';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio';

  @override
  String get invalidEmail => 'Por favor ingresa un correo válido';

  @override
  String get phoneOptional => 'Teléfono (Opcional)';

  @override
  String get enterPhone => 'Ingresa tu número de teléfono';

  @override
  String get bioOptional => 'Biografía (Opcional)';

  @override
  String get tellAboutYourself => 'Cuéntanos sobre ti';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get profileUpdated => 'Perfil actualizado exitosamente';

  @override
  String profileUpdateFailed(String error) {
    return 'Error al actualizar el perfil: $error';
  }

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get uploadDocumentTitle => 'Subir documento';

  @override
  String get selectTemplate => 'Seleccionar plantilla';

  @override
  String get chooseTemplate => 'Elegir una plantilla';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get chooseFile => 'Elegir un archivo para subir';

  @override
  String get upload => 'Subir';

  @override
  String get uploadSuccess => '¡Documento subido exitosamente!';

  @override
  String get uploadError => 'Error al subir';

  @override
  String get analysisResults => 'Resultados del análisis';

  @override
  String get documentAnalysis => 'Análisis del documento';

  @override
  String get analyzingUnderscore => 'Analizando...';

  @override
  String get analysisComplete => 'Análisis completo';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get adminPanel => 'Panel de administración';

  @override
  String get general => 'General';

  @override
  String get users => 'Usuarios';

  @override
  String get templates => 'Plantillas';

  @override
  String get systemConfig => 'Configuración del sistema';

  @override
  String get printPrice => 'Precio de impresión';

  @override
  String get dueDate => 'Fecha de vencimiento';

  @override
  String get updateConfig => 'Actualizar configuración';

  @override
  String get userManagement => 'Gestión de usuarios';

  @override
  String get totalUsers => 'Total de usuarios';

  @override
  String get addUser => 'Añadir usuario';

  @override
  String get roleUnderscore => 'Rol';

  @override
  String get template => 'Plantilla';

  @override
  String get addTemplate => 'Añadir plantilla';

  @override
  String get editTemplate => 'Editar plantilla';

  @override
  String get deleteTemplate => 'Eliminar plantilla';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get student => 'Estudiante';

  @override
  String get adminRole => 'Administrador';
}
