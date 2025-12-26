import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

import '../l10n/app_localizations.dart';
import 'tabs/home_view.dart';
import 'tabs/chat_view.dart';
import 'tabs/history_view.dart';
import 'tabs/receipts_view.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen width
    final bool isSmallScreen = screenWidth < 360;
    final double iconSize = isSmallScreen ? 20.0 : 24.0;
    final double bottomRadius = isSmallScreen ? 20.0 : 28.0;

    // Build pages list based on user role
    final List<Widget> bottomBarPages = [
      const HomeView(),
      const ChatView(),
      const HistoryView(),
      const ReceiptsView(),
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
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Switched to ${l10n.student} role'),
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
          ? SizedBox(
              width: screenWidth,
              child: AnimatedNotchBottomBar(
                key: ValueKey(bottomBarPages.length),
                color: Theme.of(context).cardColor,
                onTap: (index) {
                  _pageController.jumpToPage(index);
                },
                kIconSize: iconSize,
                kBottomRadius: bottomRadius,
                notchBottomBarController: _controller,
                itemLabelStyle: TextStyle(
                  fontSize: isSmallScreen ? 10.0 : 12.0,
                ),
                bottomBarWidth: screenWidth,
                durationInMilliSeconds: 300,
                bottomBarItems: [
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.home_filled,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withOpacity(0.5),
                      size: iconSize,
                    ),
                    activeItem: Icon(
                      Icons.home_filled,
                      color: Theme.of(context).primaryColor,
                      size: iconSize,
                    ),
                    itemLabel: l10n.home,
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.chat_bubble_outline,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withOpacity(0.5),
                      size: iconSize,
                    ),
                    activeItem: Icon(
                      Icons.chat_bubble,
                      color: Theme.of(context).primaryColor,
                      size: iconSize,
                    ),
                    itemLabel: l10n.chat,
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.history,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withOpacity(0.5),
                      size: iconSize,
                    ),
                    activeItem: Icon(
                      Icons.history,
                      color: Theme.of(context).primaryColor,
                      size: iconSize,
                    ),
                    itemLabel: l10n.history,
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.receipt_long_outlined,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withOpacity(0.5),
                      size: iconSize,
                    ),
                    activeItem: Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).primaryColor,
                      size: iconSize,
                    ),
                    itemLabel: 'Receipts',
                  ),
                  BottomBarItem(
                    inActiveItem: Icon(
                      Icons.person_outline,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withOpacity(0.5),
                      size: iconSize,
                    ),
                    activeItem: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: iconSize,
                    ),
                    itemLabel: l10n.profile,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
