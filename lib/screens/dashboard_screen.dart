import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'tabs/home_view.dart';
import 'tabs/chat_view.dart';
import 'tabs/history_view.dart';
import 'tabs/profile_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);

  int maxCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.role == 'admin';

    final List<Widget> bottomBarPages = [
      const HomeView(),
      const ChatView(),
      const HistoryView(),
      ProfileView(),
    ];

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doc AI',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              authProvider.toggleAdminRole();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Switched to ${!isAdmin ? l10n.adminRole : l10n.student} role',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Toggle Admin Role',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: bottomBarPages,
      ),
      extendBody: true,
      bottomNavigationBar: (bottomBarPages.length <= maxCount)
          ? AnimatedNotchBottomBar(
              key: ValueKey(bottomBarPages.length),
              color: Theme.of(context).cardColor,
              onTap: (index) {
                _pageController.jumpToPage(index);
              },
              kIconSize: 24.0,
              kBottomRadius: 28.0,
              notchBottomBarController: _controller,
              bottomBarItems: [
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.home_filled,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.home_filled,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: l10n.home,
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.chat_bubble_outline,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.chat_bubble,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: l10n.chat,
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.history,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.history,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: l10n.history,
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: l10n.profile,
                ),
              ],
            )
          : null,
    );
  }
}
