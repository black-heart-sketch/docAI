import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/document_provider.dart';
import '../../utils/share_pref.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.textTheme.bodyMedium!.color!.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Student',
                        style: theme.textTheme.headlineMedium!.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.cardColor,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Daily Insight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Insight',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Consistent formatting improves readability by 40%.',
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Quick Actions",
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    context,
                    'Upload',
                    Icons.upload_file,
                    Colors.blueAccent,
                    () async {
                      final spf = CustomSharePref();
                      final isLoggedIn = await spf.isLoggedIn();
                      if (context.mounted) {
                        if (isLoggedIn) {
                          context.go('/dashboard/upload');
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Account Required'),
                              content: const Text(
                                'Please create an account or log in to upload documents.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.go('/login');
                                  },
                                  child: const Text('Login / Sign Up'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                  ),
                  _buildQuickAction(
                    context,
                    'Scan',
                    Icons.document_scanner,
                    Colors.purpleAccent,
                    () {}, // TODO: Implement camera scan
                  ),
                  _buildQuickAction(
                    context,
                    'Templates',
                    Icons.copy_all,
                    Colors.orangeAccent,
                    () {}, // TODO: Implement templates
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Activity",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {}, // TODO: Navigate to history tab logic
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium!.color!.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recent Activity List Consumer
              Consumer<DocumentProvider>(
                builder: (ctx, docProvider, child) {
                  if (docProvider.isUploading) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircularProgressIndicator.adaptive(),
                          const SizedBox(width: 15),
                          const Text(
                            "Analyzing current document...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  if (docProvider.currentDocument != null) {
                    return _buildRecentCard(
                      context,
                      docProvider.currentDocument!,
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 40,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No recent activity",
                          style: TextStyle(color: theme.disabledColor),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 80), // Space for bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCard(BuildContext context, dynamic doc) {
    final theme = Theme.of(context);
    // Basic recent card implementation
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.filename,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${doc.analysisStatus}',
                  style: theme.textTheme.bodySmall!.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        ],
      ),
    );
  }
}
