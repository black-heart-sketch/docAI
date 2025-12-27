import 'dart:typed_data'; // For Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/models/template.dart';

import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_provider.dart';
import '../core/providers/document_provider.dart';
import '../core/providers/template_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? _selectedFileName;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _selectedTemplateId;

  @override
  void initState() {
    super.initState();
    // Fetch templates as soon as the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TemplateProvider>(context, listen: false).fetchTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use multiple consumers to listen to different providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Provider.of<AuthProvider>(context)),
        ChangeNotifierProvider.value(
          value: Provider.of<TemplateProvider>(context),
        ),
        ChangeNotifierProvider.value(
          value: Provider.of<DocumentProvider>(context),
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Upload Document',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New Submission',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your document and a template to begin analysis.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // --- File Picker Section ---
                    _buildFilePicker(),
                    const SizedBox(height: 20),

                    // --- Template Dropdown Section ---
                    _buildTemplateDropdown(),
                    const SizedBox(height: 40),

                    // --- Upload Button Section ---
                    _buildUploadButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the file picker UI
  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select File',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(_selectedFileName ?? 'Choose a File'),
            onPressed: () async {
              // Only load data into memory on Web (where path is unavailable)
              final result = await FilePicker.platform.pickFiles(
                withData: kIsWeb,
              );

              if (result != null) {
                debugPrint('File picked: ${result.files.single.name}');
                if (!kIsWeb) {
                  debugPrint('File path: ${result.files.single.path}');
                }
                debugPrint(
                  'File bytes length: ${result.files.single.bytes?.length}',
                );
                debugPrint('kIsWeb: $kIsWeb');

                setState(() {
                  _selectedFileName = result.files.single.name;
                  _selectedFilePath = kIsWeb ? null : result.files.single.path;
                  _selectedFileBytes = result.files.single.bytes;
                });
              } else {
                debugPrint('File picking cancelled or failed.');
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(
                context,
              ).cardColor, // Use card color or grey
              foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the template dropdown UI
  Widget _buildTemplateDropdown() {
    return Consumer<TemplateProvider>(
      builder: (ctx, templateProvider, child) {
        if (templateProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Template',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTemplateId,
              hint: const Text('Choose a template...'),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              items: templateProvider.templates.map((template) {
                return DropdownMenuItem(
                  value: template.id,
                  child: Text(
                    template.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTemplateId = value;
                });
              },
            ),
            if (_selectedTemplateId != null) ...[
              const SizedBox(height: 20),
              _buildTemplateStructurePreview(
                templateProvider.templates.firstWhere(
                  (t) => t.id == _selectedTemplateId,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Widget for the upload button UI
  Widget _buildUploadButton() {
    return Consumer2<AuthProvider, DocumentProvider>(
      builder: (ctx, authProvider, docProvider, child) {
        final isReady =
            _selectedFileName != null && _selectedTemplateId != null;
        final isUploading = docProvider.isUploading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            // Use default theme style or specific overrides if needed
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: (isReady && !isUploading)
                ? () {
                    debugPrint(
                      'Upload button pressed. Bytes present: ${_selectedFileBytes != null}',
                    );
                    if (authProvider.user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to upload documents.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    docProvider.uploadAndAnalyze(
                      _selectedFilePath ??
                          '', // Might be null or empty on web, but provider handles it if bytes are present
                      _selectedTemplateId!,
                      authProvider.user!.id,
                      fileBytes: _selectedFileBytes,
                      fileName: _selectedFileName,
                    );
                    // Navigate to the analysis screen to show progress
                    context.go('/dashboard/analysis');
                  }
                : null, // Disable button if not ready or already uploading
            child: isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text('Upload and Analyze'),
          ),
        );
      },
    );
  }

  Widget _buildTemplateStructurePreview(Template template) {
    if (template.structure.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Expected Structure',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: template.structure.length,
            itemBuilder: (context, index) {
              final section = template.structure[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section['section'] ?? 'Section',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (section['content'] != null)
                            Text(
                              section['content'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
