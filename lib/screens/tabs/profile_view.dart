import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../personal_info_screen.dart';
import 'admin_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _apiService = ApiService();
  int? _documentCount;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentCount();
  }

  Future<void> _loadDocumentCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) return;

    setState(() => _isLoadingStats = true);

    try {
      final docs = await _apiService.getUserDocuments(authProvider.user!.id);
      if (mounted) {
        setState(() {
          _documentCount = docs.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ...LanguageProvider.supportedLocales.map((locale) {
                final languageName =
                    LanguageProvider.languageNames[locale.languageCode] ??
                    locale.languageCode;
                final isSelected = languageProvider.currentLocale == locale;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.language,
                    color: isSelected
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    languageName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    languageProvider.setLanguage(locale);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access theme from context (provided by ThemeProvider in main.dart)
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Dynamic gradient based on theme? Or strictly use theme background?
    // User requested specific backgrounds.
    // White: White bg. Blue: Deep Blue. Black: Soft Black.
    // We configured scaffoldBackgroundColor in AppTheme, so we can use that if we remove the gradient container
    // OR we can reconstruct a gradient if needed.
    // For now, let's respect the scaffoldBackgroundColor.

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final l10n = AppLocalizations.of(context)!;
            final user = authProvider.user;
            final isAuthenticated = authProvider.isAuthenticated;

            if (!isAuthenticated) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.profileRestricted,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(l10n.pleaseLogin, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => context.go('/login'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(l10n.login),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Header
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.canvasColor,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text(
                    user?.name ?? 'Student Name',
                    style: theme.textTheme.displaySmall!.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'student@university.edu',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.textTheme.bodyMedium!.color!.withOpacity(
                        0.7,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Stats Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(
                        0.1,
                      ), // Or explicit card color
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _isLoadingStats
                            ? const SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _buildStatItem(
                                context,
                                _documentCount?.toString() ?? '0',
                                l10n.documents,
                              ),
                        Container(
                          height: 40,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        _buildStatItem(context, '85%', l10n.avgScore),
                        Container(
                          height: 40,
                          width: 1,
                          color: theme.dividerColor,
                        ),
                        _buildStatItem(
                          context,
                          user?.role == 'admin' ? l10n.adminRole : l10n.student,
                          l10n.role,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Admin Dashboard Access
                  if (user?.role == 'admin' || user?.role == 'class_prefect')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            l10n.adminDashboard,
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          subtitle: Text(l10n.managePricesUsersTemplates),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AdminView(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Settings Sections
                  _buildSettingsGroup(context, l10n.account, [
                    _buildSettingsTile(
                      Icons.person_outline,
                      l10n.personalInformation,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                      context: context,
                    ),
                    _buildSettingsTile(
                      Icons.lock_outline,
                      l10n.security,
                      () {},
                      context: context,
                    ),
                    _buildSettingsTile(
                      Icons.payment_outlined,
                      l10n.paymentMethods,
                      () {},
                      context: context,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _buildSettingsGroup(context, l10n.preferences, [
                    _buildSettingsTile(
                      Icons.notifications_outlined,
                      l10n.notifications,
                      () {},
                      context: context,
                    ),
                    _buildSettingsTile(
                      Icons.language_outlined,
                      l10n.language,
                      () => _showLanguageSelector(context),
                      context: context,
                      trailing: Consumer<LanguageProvider>(
                        builder: (ctx, langProvider, _) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                LanguageProvider.languageNames[langProvider
                                        .currentLocale
                                        .languageCode] ??
                                    'EN',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          );
                        },
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        l10n.appTheme,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: DropdownButton<AppThemeMode>(
                        value: themeProvider.currentMode,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (AppThemeMode? newValue) {
                          if (newValue != null) {
                            themeProvider.setTheme(newValue);
                          }
                        },
                        items: AppThemeMode.values
                            .map<DropdownMenuItem<AppThemeMode>>((
                              AppThemeMode mode,
                            ) {
                              return DropdownMenuItem<AppThemeMode>(
                                value: mode,
                                child: Text(mode.name.toUpperCase()),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),
                  _buildSettingsGroup(context, l10n.support, [
                    _buildSettingsTile(
                      Icons.help_outline,
                      l10n.helpCenter,
                      () {},
                      context: context,
                    ),
                    _buildSettingsTile(
                      Icons.info_outline,
                      l10n.aboutDocAI,
                      () {},
                      context: context,
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // Logout Button
                  TextButton.icon(
                    onPressed: () {
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logout();
                      context.go('/login');
                    },
                    icon: Icon(Icons.logout, color: theme.colorScheme.error),
                    label: Text(
                      l10n.logout,
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom bar space
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.textTheme.bodySmall!.color!.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            title,
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
