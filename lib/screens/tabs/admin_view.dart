import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user.dart';
import '../../core/models/template.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final ApiService _apiService = ApiService();
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);

  // State
  List<Map<String, dynamic>> _pricingTiers = [];
  List<User> _users = [];
  List<Template> _templates = [];
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _receipts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _currentIndex = 0;
  String? _selectedUserClassFilter;
  String? _selectedDocumentClassFilter;
  String _receiptSearchQuery = '';
  String _selectedReceiptClassFilter = 'All';
  String _selectedReceiptStatusFilter = 'all';

  final List<String> _classOptions = ['All', 'BA1A', 'BA1B', 'BA1C', 'BA1D'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userRole = authProvider.user?.role;
      final userClass = authProvider.user?.className;

      final tiers = await _apiService.getPricingTiers();
      final users = await _apiService.getUsers();
      final templates = await _apiService.getTemplates();
      final documents = await _apiService.getAllDocuments();

      // If class prefect, only fetch receipts from their class
      List<Map<String, dynamic>> receipts;
      if (userRole == 'class_prefect' && userClass != null) {
        receipts = await _apiService.getAllReceipts(userClass: userClass);
      } else {
        receipts = await _apiService.getAllReceipts();
      }

      if (mounted) {
        setState(() {
          _pricingTiers = tiers;
          _users = users;
          _templates = templates;
          _documents = documents;
          _receipts = receipts;
          if (userRole == 'class_prefect' && userClass != null) {
            _selectedReceiptClassFilter = userClass;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading admin data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _activateTier(String id) async {
    try {
      await _apiService.activatePricingTier(id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tier activated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to activate tier: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTier(String id) async {
    try {
      await _apiService.deletePricingTier(id);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete tier: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showTierDialog({Map<String, dynamic>? tier}) async {
    final nameController = TextEditingController(text: tier?['name'] ?? '');
    final priceController = TextEditingController(
      text: tier?['price_cents']?.toString() ?? '',
    );
    DateTime? selectedDate = tier?['due_date'] != null
        ? DateTime.tryParse(tier!['due_date'])
        : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(tier == null ? 'New Pricing Tier' : 'Edit Tier'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tier Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (cents)'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setStateDialog(() => selectedDate = picked);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate == null
                          ? 'Select Due Date (Optional)'
                          : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  return;
                }
                Navigator.pop(context);
                setState(() => _isLoading = true);

                final data = {
                  'name': nameController.text,
                  'price_cents': int.parse(priceController.text),
                  'due_date': selectedDate?.toIso8601String().split('T')[0],
                };

                try {
                  if (tier == null) {
                    await _apiService.createPricingTier(data);
                  } else {
                    await _apiService.updatePricingTier(tier['id'], data);
                  }
                  _loadData();
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final isClassPrefect = user?.role == 'class_prefect';

    // For class_prefect, show only receipts tab
    final List<Widget> bottomBarPages = isClassPrefect
        ? [_buildReceiptsTab()]
        : [
            _buildGeneralTab(),
            _buildUsersTab(),
            _buildTemplatesTab(),
            _buildDocumentsTab(),
            _buildReceiptsTab(),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: bottomBarPages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: () => _showTemplateDialog(),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      extendBody: true,
      bottomNavigationBar: AnimatedNotchBottomBar(
        key: ValueKey(bottomBarPages.length),
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        kIconSize: 24.0,
        kBottomRadius: 28.0,
        color: Theme.of(context).cardColor,
        notchBottomBarController: _controller,
        bottomBarItems: isClassPrefect
            ? [
                // Only Receipts for class_prefect
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.receipt_long_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: 'Receipts',
                ),
              ]
            : [
                // All tabs for admin
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: 'General',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.people_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.people,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: 'Users',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.description,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: 'Templates',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.folder_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.folder,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: 'Documents',
                ),
                BottomBarItem(
                  inActiveItem: Icon(
                    Icons.receipt_long_outlined,
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.5),
                  ),
                  activeItem: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                  ),
                  itemLabel: 'Receipts',
                ),
              ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pricing Tiers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () => _showTierDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Tier'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_pricingTiers.isEmpty)
            const Center(child: Text("No pricing tiers defined."))
          else
            ..._pricingTiers.map((tier) {
              final isActive = tier['is_active'] == true;
              return Card(
                elevation: isActive ? 4 : 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isActive
                      ? BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        tier['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tier['price_cents']} cents'),
                      if (tier['due_date'] != null)
                        Text('Due: ${tier['due_date']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isActive)
                        TextButton(
                          onPressed: () => _activateTier(tier['id']),
                          child: const Text('Activate'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTierDialog(tier: tier),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTier(tier['id']),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = _users.where((user) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      // Apply class filter
      if (_selectedUserClassFilter != null &&
          _selectedUserClassFilter != 'All' &&
          _selectedUserClassFilter!.isNotEmpty) {
        return matchesSearch &&
            (user.className ?? '') == _selectedUserClassFilter;
      }

      return matchesSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search users...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedUserClassFilter,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  hintText: 'Filter by class',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _classOptions.map((String className) {
                  return DropdownMenuItem<String>(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUserClassFilter = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(user.email),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.role == 'admin'
                                    ? Colors.redAccent.withOpacity(0.1)
                                    : Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: user.role == 'admin'
                                      ? Colors.redAccent.withOpacity(0.5)
                                      : Colors.blueAccent.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                user.role.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: user.role == 'admin'
                                      ? Colors.redAccent
                                      : Colors.blueAccent,
                                ),
                              ),
                            ),
                            if (user.className != null &&
                                user.className!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  user.className!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          _showEditUserDialog(user);
                        } else if (value == 'Delete') {
                          // TODO: Implement delete
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Delete not implemented'),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              "No templates found.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.secondary.withOpacity(0.2),
              child: Icon(
                Icons.article,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            title: Text(
              template.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'ID: ${template.id}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showTemplateDialog(template: template),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTemplate(template.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTemplateDialog({Template? template}) async {
    final nameController = TextEditingController(text: template?.name ?? '');

    // Structure logic: simple list of Maps for now
    List<Map<String, dynamic>> structure = [];
    if (template != null) {
      structure = List.from(template.structure);
    } else {
      // Default empty structure
      structure = [];
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(template == null ? 'New Template' : 'Edit Template'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Template Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sections',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: () {
                              setStateDialog(() {
                                structure.add({'section': '', 'content': ''});
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (structure.isEmpty)
                        const Text(
                          'No sections defined.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ...structure.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: item['section'],
                                        decoration: const InputDecoration(
                                          labelText: 'Section Title',
                                          isDense: true,
                                        ),
                                        onChanged: (val) =>
                                            structure[index]['section'] = val,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setStateDialog(() {
                                          structure.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  initialValue: item['content'],
                                  decoration: const InputDecoration(
                                    labelText: 'Description / Content',
                                    isDense: true,
                                  ),
                                  onChanged: (val) =>
                                      structure[index]['content'] = val,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    Navigator.pop(context);
                    setState(() => _isLoading = true);

                    try {
                      // Filter out empty sections
                      final cleanStructure = structure
                          .where(
                            (s) =>
                                s['section'].toString().isNotEmpty ||
                                s['content'].toString().isNotEmpty,
                          )
                          .toList();

                      if (template == null) {
                        // Create
                        final newTemplate = Template(
                          id: DateTime.now().millisecondsSinceEpoch
                              .toString(), // Mock ID gen
                          name: nameController.text,
                          structure: cleanStructure,
                        );
                        await _apiService.createTemplate(newTemplate);
                      } else {
                        // Update
                        final updatedTemplate = Template(
                          id: template.id,
                          name: nameController.text,
                          structure: cleanStructure,
                        );
                        await _apiService.updateTemplate(updatedTemplate);
                      }
                      _loadData(); // Reload
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      setState(() => _isLoading = false);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTemplate(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('Are you sure you want to delete this template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _apiService.deleteTemplate(id);
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildDocumentsTab() {
    final filteredDocs = _documents.where((doc) {
      final query = _searchQuery.toLowerCase();
      final filename = (doc['filename'] ?? '').toLowerCase();
      final userName = (doc['user_name'] ?? '').toLowerCase();
      final userEmail = (doc['user_email'] ?? '').toLowerCase();
      final matchesSearch =
          filename.contains(query) ||
          userName.contains(query) ||
          userEmail.contains(query);

      // Apply class filter
      if (_selectedDocumentClassFilter != null &&
          _selectedDocumentClassFilter != 'All' &&
          _selectedDocumentClassFilter!.isNotEmpty) {
        final userClass = doc['user_class'] ?? '';
        return matchesSearch && userClass == _selectedDocumentClassFilter;
      }

      return matchesSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by filename or user...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDocumentClassFilter,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  hintText: 'Filter by class',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _classOptions.map((String className) {
                  return DropdownMenuItem<String>(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDocumentClassFilter = newValue;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredDocs.length} documents',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredDocs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? "No documents uploaded yet."
                            : "No documents match your search.",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final status = doc['analysis_status'] ?? 'unknown';
                    final paymentStatus = doc['payment_status'] ?? 'unpaid';

                    Color statusColor;
                    IconData statusIcon;
                    switch (status) {
                      case 'completed':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'analyzing':
                        statusColor = Colors.orange;
                        statusIcon = Icons.hourglass_empty;
                        break;
                      case 'failed':
                        statusColor = Colors.red;
                        statusIcon = Icons.error;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.pending;
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        onTap: () => _showDocumentDetailDialog(doc),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: statusColor.withOpacity(0.2),
                          child: Icon(statusIcon, color: statusColor, size: 24),
                        ),
                        title: Text(
                          doc['filename'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    doc['user_name'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    doc['user_email'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: paymentStatus == 'paid'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: paymentStatus == 'paid'
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.orange.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: paymentStatus == 'paid'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              doc['created_at'] != null
                                  ? _formatDate(doc['created_at'])
                                  : 'N/A',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${doc['page_count'] ?? 0} pages',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showDocumentDetailDialog(Map<String, dynamic> doc) {
    final status = doc['analysis_status'] ?? 'unknown';
    final analysisResult = doc['analysis_result'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.description, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                doc['filename'] ?? 'Document Details',
                style: const TextStyle(fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Information
                _buildDetailSection('User Information', [
                  _buildDetailRow(
                    Icons.person,
                    'Name',
                    doc['user_name'] ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    Icons.email,
                    'Email',
                    doc['user_email'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.badge,
                    'Student ID',
                    doc['student_id'] ?? 'N/A',
                  ),
                ]),
                const Divider(height: 24),

                // Document Information
                _buildDetailSection('Document Information', [
                  _buildDetailRow(
                    Icons.insert_drive_file,
                    'Filename',
                    doc['filename'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.fingerprint,
                    'Document ID',
                    doc['id'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.description_outlined,
                    'Template ID',
                    doc['template_id'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    Icons.pages,
                    'Page Count',
                    '${doc['page_count'] ?? 0} pages',
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Upload Date',
                    doc['created_at'] != null
                        ? _formatDate(doc['created_at'])
                        : 'N/A',
                  ),
                ]),
                const Divider(height: 24),

                // Status Information
                _buildDetailSection('Status', [
                  Row(
                    children: [
                      const Icon(Icons.analytics, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Analysis:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getStatusColor(status)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: doc['payment_status'] == 'paid'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: doc['payment_status'] == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        child: Text(
                          (doc['payment_status'] ?? 'unpaid').toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: doc['payment_status'] == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),

                // Analysis Result / Feedback
                if (analysisResult != null) ...[
                  const Divider(height: 24),
                  _buildDetailSection('Analysis Feedback', [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: _buildAnalysisResult(analysisResult),
                    ),
                  ]),
                ] else if (status == 'completed') ...[
                  const Divider(height: 24),
                  const Text(
                    'Analysis Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analysis completed but no feedback available.',
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else if (status == 'analyzing') ...[
                  const Divider(height: 24),
                  const Text(
                    'Analysis Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Analysis in progress...',
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(dynamic result) {
    if (result is String) {
      return Text(result);
    } else if (result is Map) {
      // If analysis result is a map/JSON, display it properly
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: result.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.value?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Text(result?.toString() ?? 'No feedback available');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'analyzing':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReceiptsTab() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role;
    final isAdmin = userRole == 'admin';

    // Apply filters
    final filteredReceipts = _receipts.where((receipt) {
      final matchesSearch =
          _receiptSearchQuery.isEmpty ||
          (receipt['receipt_number']?.toString().toLowerCase().contains(
                _receiptSearchQuery.toLowerCase(),
              ) ??
              false);

      final matchesStatus =
          _selectedReceiptStatusFilter == 'all' ||
          receipt['status'] == _selectedReceiptStatusFilter;

      final matchesClass =
          !isAdmin ||
          _selectedReceiptClassFilter == 'All' ||
          receipt['user_class'] == _selectedReceiptClassFilter;

      return matchesSearch && matchesStatus && matchesClass;
    }).toList();

    return Column(
      children: [
        // Search and Filters
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    _receiptSearchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Receipt #',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Class Filter
                    _buildFilterLabel('Class:'),
                    const SizedBox(width: 8),
                    _buildFilterContainer(
                      child: DropdownButton<String>(
                        value: _selectedReceiptClassFilter,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).primaryColor,
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        items:
                            (isAdmin
                                    ? _classOptions
                                    : [_selectedReceiptClassFilter])
                                .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                })
                                .toList(),
                        onChanged: isAdmin
                            ? (value) {
                                setState(() {
                                  _selectedReceiptClassFilter = value ?? 'All';
                                });
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Filter
                    _buildFilterLabel('Status:'),
                    const SizedBox(width: 8),
                    _buildFilterContainer(
                      child: DropdownButton<String>(
                        value: _selectedReceiptStatusFilter,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).primaryColor,
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'validated',
                            child: Text('Validated'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedReceiptStatusFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Receipts list
        Expanded(
          child: filteredReceipts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _receiptSearchQuery.isEmpty
                            ? 'No receipts found'
                            : 'No receipts match your search',
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReceipts.length,
                  itemBuilder: (context, index) {
                    final receipt = filteredReceipts[index];
                    return _buildReceiptCard(receipt);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReceiptCard(Map<String, dynamic> receipt) {
    final theme = Theme.of(context);
    final status = receipt['status'] as String? ?? 'pending';
    final receiptNumber = receipt['receipt_number'] as String? ?? 'N/A';
    final amount = receipt['amount'] as int? ?? 0;
    final filename = receipt['document_filename'] as String? ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt #$receiptNumber',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filename,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildReceiptStatusBadge(status),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$amount XAF',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                if (receipt['user_class'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      receipt['user_class'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),

            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectReceipt(receipt['_id']),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _validateReceipt(receipt['_id']),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Validate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'validated':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateReceipt(String receiptId) async {
    try {
      await _apiService.validateReceipt(receiptId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt validated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectReceipt(String receiptId) async {
    try {
      await _apiService.rejectReceipt(receiptId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedClass = user.className ?? '';
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedClass.isEmpty ? null : selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select Class'),
                  items: _classOptions.map((className) {
                    return DropdownMenuItem(
                      value: className,
                      child: Text(className),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedClass = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(
                      value: 'class_prefect',
                      child: Text('Class Prefect'),
                    ),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      selectedRole = value ?? 'student';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiService.updateUser(user.id, {
                    'name': nameController.text,
                    'class_name': selectedClass.isEmpty ? null : selectedClass,
                    'role': selectedRole,
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  Widget _buildFilterContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: child,
    );
  }
}
