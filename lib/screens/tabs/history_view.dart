import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/document.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/document_provider.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final ApiService _apiService = ApiService();
  late Future<List<Document>> _documentsFuture;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _documentsFuture = _apiService.getUserDocuments(authProvider.user!.id);
    } else {
      // If not logged in, we don't fetch anything. The UI will handle showing the prompt.
      _documentsFuture = Future.value([]);
    }
  }

  List<Document> _filterDocuments(List<Document> documents) {
    if (_selectedFilter == 'All') return documents;
    if (_selectedFilter == 'Completed') {
      return documents
          .where((doc) => doc.analysisStatus == 'completed')
          .toList();
    }
    if (_selectedFilter == 'Pending') {
      return documents
          .where(
            (doc) =>
                doc.analysisStatus != 'completed' &&
                doc.analysisStatus != 'failed',
          )
          .toList();
    }
    if (_selectedFilter == 'Failed') {
      return documents.where((doc) => doc.analysisStatus == 'failed').toList();
    }
    return documents;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'History',
          style: theme.textTheme.headlineSmall!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _loadDocuments();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: theme.primaryColor,
            padding: const EdgeInsets.only(bottom: 20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Completed', 'Pending', 'Failed'].map((
                  filter,
                ) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white10,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? theme.primaryColor
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.user == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Please log in to view history',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  );
                }

                return FutureBuilder<List<Document>>(
                  future: _documentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading history\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _loadDocuments();
                                });
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No documents found'),
                          ],
                        ),
                      );
                    }

                    final filteredDocs = _filterDocuments(snapshot.data!);

                    if (filteredDocs.isEmpty) {
                      return const Center(
                        child: Text("No documents match filter"),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        return _buildHistoryCard(context, doc);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Document doc) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (doc.paymentStatus == 'paid') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Paid';
    } else if (doc.analysisStatus == 'failed') {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'Failed';
    } else if (doc.analysisStatus == 'completed') {
      // Unpaid & Completed
      statusColor = Colors.orange;
      statusIcon = Icons.payment;
      statusText = 'Unpaid';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.hourglass_top;
      statusText = 'Pending'; // Analyzing
    }

    // Attempt to get score if available
    String? score;
    if (doc.analysisResult != null &&
        doc.analysisResult!['accuracy_score'] != null) {
      score = "${doc.analysisResult!['accuracy_score']}%";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Set current doc and navigate
            Provider.of<DocumentProvider>(
              context,
              listen: false,
            ).setCurrentDocument(doc);
            context.go('/dashboard/analysis');
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: Icon(statusIcon, color: statusColor)),
                ),
                const SizedBox(width: 15),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.filename,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        // No date in model yet, showing ID suffix or simpler text
                        "Doc ID: ...${doc.id.substring(doc.id.length - 6)}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Status/Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        score != null ? "$score Match" : statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (statusText == 'Unpaid') ...[
                      const SizedBox(height: 4),
                      const Text(
                        "Tap to Pay",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
