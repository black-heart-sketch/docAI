import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/document_provider.dart';
import '../../core/providers/template_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/document.dart';
import '../../core/models/template.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  bool _isTyping = false;

  // Mode: 'document' or 'template'
  String _chatMode = 'document';
  Template? _currentTemplate;

  // Reply context
  Map<String, dynamic>? _replyingTo;

  // History format: { 'isUser': bool, 'message': String, 'time': String }
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'message':
          'Hello! I am Doc AI. Select a document or template to start chatting.',
      'time': 'Now',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Fetch data if needed
    Future.microtask(() {
      Provider.of<TemplateProvider>(context, listen: false).fetchTemplates();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final currentDoc = docProvider.currentDocument;

    // Validation
    if (_chatMode == 'document' && currentDoc == null) {
      _showContextPicker();
      return;
    }
    if (_chatMode == 'template' && _currentTemplate == null) {
      _showContextPicker();
      return;
    }

    setState(() {
      _messages.add({'isUser': true, 'message': text, 'time': 'Now'});
      _isTyping = true;
      _replyingTo = null; // Clear reply context
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      // Prepare history for API (last 5 messages)
      final historyForApi = _messages
          .skip(1)
          .take(_messages.length - 2)
          .map((m) => {'isUser': m['isUser'], 'message': m['message']})
          .toList();

      String response;
      if (_chatMode == 'document') {
        response = await _apiService.chatDocument(
          currentDoc!.id,
          text,
          historyForApi,
        );
      } else {
        response = await _apiService.chatTemplate(
          _currentTemplate!.id,
          text,
          historyForApi,
        );
      }

      if (mounted) {
        setState(() {
          _messages.add({'isUser': false, 'message': response, 'time': 'Now'});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'message': 'Error: $e',
            'time': 'Now',
          });
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _sanitizeText(String text) {
    // Remove markdown formatting characters
    return text
        .replaceAll(RegExp(r'\*+'), '') // Remove asterisks (* ** ***)
        .replaceAll(
          RegExp(r'#+\s'),
          '',
        ) // Remove hashtags with space (# ## ###)
        .replaceAll(RegExp(r'`+'), '') // Remove backticks
        .replaceAll(RegExp(r'~~'), '') // Remove strikethrough
        .replaceAll(RegExp(r'__'), '') // Remove underscores
        .trim();
  }

  List<TextSpan> _parseMarkdown(String text, Color textColor) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.+?)\*\*');
    int lastMatchEnd = 0;

    for (final match in boldRegex.allMatches(text)) {
      // Add normal text before the match
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: TextStyle(color: textColor, fontSize: 15),
          ),
        );
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text after last match
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      );
    }

    // If no matches found, return plain text
    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      );
    }

    return spans;
  }

  void _showMessageActions(Map<String, dynamic> message) {
    final theme = Theme.of(context);
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
              ListTile(
                leading: Icon(Icons.copy, color: theme.primaryColor),
                title: Text(
                  'Copy',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                onTap: () {
                  final sanitizedText = _sanitizeText(message['message']);
                  Clipboard.setData(ClipboardData(text: sanitizedText));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Message copied'),
                      backgroundColor: theme.primaryColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.reply, color: theme.primaryColor),
                title: Text(
                  'Reply',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                onTap: () {
                  setState(() {
                    _replyingTo = message;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showContextPicker() async {
    final docProvider = Provider.of<DocumentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Fetch user docs dynamically when picker opens
    List<Document> userDocs = [];
    if (authProvider.user != null) {
      try {
        userDocs = await _apiService.getUserDocuments(authProvider.user!.id);
      } catch (e) {
        debugPrint("Error fetching docs for picker: $e");
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return DefaultTabController(
          length: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                TabBar(
                  labelColor: theme.colorScheme.onSurface,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                    0.6,
                  ),
                  indicatorColor: theme.primaryColor,
                  tabs: const [
                    Tab(text: "Documents"),
                    Tab(text: "Templates"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Documents Tab
                      userDocs.isEmpty
                          ? Center(
                              child: Text(
                                "No documents found.",
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: userDocs.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (ctx, i) {
                                final doc = userDocs[i];
                                return ListTile(
                                  leading: Icon(
                                    Icons.description,
                                    color: theme.primaryColor,
                                  ),
                                  title: Text(
                                    doc.filename,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    doc.analysisStatus,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _chatMode = 'document';
                                      docProvider.setCurrentDocument(doc);
                                      _messages.clear();
                                      _messages.add({
                                        'isUser': false,
                                        'message':
                                            'Switched context to document: ${doc.filename}. What would you like to know?',
                                        'time': 'Now',
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),

                      // Templates Tab
                      Consumer<TemplateProvider>(
                        builder: (ctx, tplProvider, _) {
                          if (tplProvider.isLoading)
                            return Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            );
                          if (tplProvider.templates.isEmpty)
                            return Center(
                              child: Text(
                                "No templates available.",
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            );

                          return ListView.separated(
                            itemCount: tplProvider.templates.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (ctx, i) {
                              final tpl = tplProvider.templates[i];
                              return ListTile(
                                leading: Icon(
                                  Icons.article,
                                  color: theme.primaryColor.withOpacity(0.8),
                                ),
                                title: Text(
                                  tpl.name,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _chatMode = 'template';
                                    _currentTemplate = tpl;
                                    // Clear doc to avoid confusion
                                    _messages.clear();
                                    _messages.add({
                                      'isUser': false,
                                      'message':
                                          'Switched context to template: ${tpl.name}. I can explain its structure.',
                                      'time': 'Now',
                                    });
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final docProvider = Provider.of<DocumentProvider>(context);

    String contextName = "Select Context";
    if (_chatMode == 'document' && docProvider.currentDocument != null) {
      contextName = docProvider.currentDocument!.filename;
    } else if (_chatMode == 'template' && _currentTemplate != null) {
      contextName = "Template: ${_currentTemplate!.name}";
    }

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.psychology, color: theme.iconTheme.color),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showContextPicker,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doc AI Chat',
                            style: theme.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  contextName,
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: theme.iconTheme.color,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.history, color: theme.iconTheme.color),
                    tooltip: "Switch Context",
                    onPressed: _showContextPicker,
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            return _buildMessageBubble(msg);
                          },
                        ),
                      ),
                      if (_isTyping)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Doc AI is typing...",
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.transparent,
              child: Column(
                children: [
                  // Suggested Prompts
                  if (_messages.length < 2)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSuggestionChip(
                            _chatMode == 'document'
                                ? 'Summarize this'
                                : 'Explain structure',
                          ),
                          _buildSuggestionChip('Key points'),
                          _buildSuggestionChip('Suggestions?'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Reply Preview
                  if (_replyingTo != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Replying to ${_replyingTo!['isUser'] ? 'yourself' : 'Doc AI'}',
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _sanitizeText(_replyingTo!['message']),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: theme.colorScheme.onSurface,
                            ),
                            onPressed: () {
                              setState(() {
                                _replyingTo = null;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Ask about $contextName...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                          enabled:
                              (docProvider.currentDocument != null ||
                                  (_chatMode == 'template' &&
                                      _currentTemplate != null)) &&
                              !_isTyping,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: theme.colorScheme.onPrimary,
                          ),
                          onPressed:
                              (docProvider.currentDocument != null ||
                                      (_chatMode == 'template' &&
                                          _currentTemplate != null)) &&
                                  !_isTyping
                              ? _sendMessage
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final theme = Theme.of(context);
    final message = msg['message'] as String;
    final isUser = msg['isUser'] as bool;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageActions(msg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: isUser ? theme.primaryColor : theme.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: isUser
                  ? const Radius.circular(20)
                  : const Radius.circular(0),
              topRight: const Radius.circular(20),
              bottomLeft: const Radius.circular(20),
              bottomRight: isUser
                  ? const Radius.circular(0)
                  : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: RichText(
            text: TextSpan(
              children: _parseMarkdown(
                message,
                isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.cardColor,
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          _messageController.text = label;
          _sendMessage();
        },
      ),
    );
  }
}
