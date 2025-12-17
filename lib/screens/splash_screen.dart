import 'dart:async';
import 'package:docai/utils/share_pref.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Try to auto-login before moving on
    await Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();

    await Future.delayed(const Duration(milliseconds: 2500));
    final CustomSharePref prefs = CustomSharePref();
    final seenOnboarding = await prefs.isLoggedIn();

    if (!mounted) return;

    if (seenOnboarding) {
      context.go('/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replace with Image.asset('assets/images/logo.png') if you have one
                Icon(Icons.psychology, size: 100, color: theme.primaryColor),
                const SizedBox(height: 20),
                Text(
                  'Doc AI',
                  style: theme.textTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Intelligent Document Assistant',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  'Analyze, Chat, and Perfect.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium!.color!.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
