/**
 * Student Numbers: 223007530; 223038085; 223005893; 223051025 ; 223040545; 221034577; 222033434; 223020021; 224020157
 * Student Names  :A Jara; BF Motseki; TV Thabisi; LD MoKheti;FB Amatebelle;ML Mwenda; KD Tsolo;B Mbinga ;KP Molelekeng
 * Question: Student Assistant Application Form (Create / Update)
 */

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_theme.dart';
import '../../utils/module_data.dart';
import '../../utils/shared_widgets.dart';

class ApplicationFormView extends StatefulWidget {
  final bool isEditing;

  const ApplicationFormView({super.key, required this.isEditing});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  // Unit 4: GlobalKey to control form state and validation
  final _formKey = GlobalKey<FormState>();

  // Form Field State
  int? _yearOfStudy;
  String? _module1Level;
  String? _module1Name;
  String? _module2Level;
  String? _module2Name;
  bool _meetsRequirements = false;
  File? _selectedFile;

  // Controllers for text inputs
  final TextEditingController _studentNumberController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final appVM = context.read<ApplicationViewModel>();
    final authVM = context.read<AuthViewModel>();

    // Pre-fill user data
    _fullNameController.text = authVM.currentUser?.fullName ?? '';

    // If editing, populate the existing application data
    if (widget.isEditing && appVM.myApplication != null) {
      final app = appVM.myApplication!;
      _studentNumberController.text = app.studentNumber;
      _fullNameController.text = app.fullName;
      _yearOfStudy = app.yearOfStudy;
      _module1Level = app.module1Level;
      _module1Name = app.module1Name;
      _module2Level = app.module2Level;
      _module2Name = app.module2Name;
      _meetsRequirements = app.meetsRequirements;
    }
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // Limit to documents and images to prevent malicious uploads
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must confirm you meet the requirements.'),
            backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    // NEW: Require a document for brand new applications
    if (!widget.isEditing && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload your supporting documentation.'),
            backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    final appVM = context.read<ApplicationViewModel>();
    final authVM = context.read<AuthViewModel>();

    final application = ApplicationModel(
      id: widget.isEditing ? appVM.myApplication?.id : null,
      studentId: authVM.currentUser!.id,
      studentNumber: _studentNumberController.text.trim(),
      fullName: _fullNameController.text.trim(),
      yearOfStudy: _yearOfStudy!,
      module1Level: _module1Level!,
      module1Name: _module1Name!,
      module2Level: _module2Level,
      module2Name: _module2Name,
      meetsRequirements: _meetsRequirements,
      status: 'pending',
      // Keep existing URL if editing, otherwise it will be overwritten in ViewModel
      documentUrl: widget.isEditing ? appVM.myApplication?.documentUrl : null,
    );

    bool success;
    if (widget.isEditing) {
      // Pass the optional file to the update method
      success = await appVM.updateApplication(application.id!, application,
          documentFile: _selectedFile);
    } else {
      // Pass the required file to the submit method
      success = await appVM.submitApplication(application,
          documentFile: _selectedFile);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(appVM.successMessage ?? 'Success!'),
            backgroundColor: AppTheme.successColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ApplicationViewModel>().isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Application' : 'New Application'),
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: 'Saving application...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Personal Details',
                  subtitle: 'Verify your student information',
                ),

                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _studentNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Student Number'),
                  keyboardType: TextInputType.number,
                  // Unit 4 Regex validation for exact numbers
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required field';
                    if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Student number must contain only digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _yearOfStudy,
                  decoration:
                      const InputDecoration(labelText: 'Current Year of Study'),
                  items: [1, 2, 3, 4].map((year) {
                    return DropdownMenuItem(
                        value: year, child: Text('Year $year'));
                  }).toList(),
                  onChanged: (val) => setState(() => _yearOfStudy = val),
                  validator: (value) =>
                      value == null ? 'Please select your year' : null,
                ),

                const SizedBox(height: 32),
                const SectionHeader(
                  title: 'Primary Module',
                  subtitle: 'The main module you wish to assist with',
                ),

                // Controlled input: Level determines available modules
                DropdownButtonFormField<String>(
                  value: _module1Level,
                  decoration:
                      const InputDecoration(labelText: 'Academic Level'),
                  items: ModuleData.academicLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _module1Level = val;
                      _module1Name =
                          null; // Reset module name when level changes
                    });
                  },
                  validator: (value) => value == null ? 'Required field' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _module1Name,
                  decoration: const InputDecoration(labelText: 'Module Name'),
                  items: _module1Level == null
                      ? []
                      : ModuleData.getModulesForLevel(_module1Level!)
                          .map((module) {
                          return DropdownMenuItem(
                              value: module, child: Text(module));
                        }).toList(),
                  onChanged: (val) => setState(() => _module1Name = val),
                  validator: (value) => value == null ? 'Required field' : null,
                  disabledHint: const Text('Select an academic level first'),
                ),

                const SizedBox(height: 32),
                const SectionHeader(
                  title: 'Secondary Module (Optional)',
                  subtitle: 'Limited to a maximum of two modules',
                ),

                DropdownButtonFormField<String>(
                  value: _module2Level,
                  decoration: const InputDecoration(
                      labelText: 'Academic Level (Optional)'),
                  items: ModuleData.academicLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _module2Level = val;
                      _module2Name = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _module2Name,
                  decoration: const InputDecoration(
                      labelText: 'Module Name (Optional)'),
                  items: _module2Level == null
                      ? []
                      : ModuleData.getModulesForLevel(_module2Level!)
                          .map((module) {
                          return DropdownMenuItem(
                              value: module, child: Text(module));
                        }).toList(),
                  onChanged: (val) => setState(() => _module2Name = val),
                ),

                const SizedBox(height: 32),
                const SectionHeader(
                  title: 'Supporting Documentation',
                  subtitle:
                      'Upload your academic record/proof of eligibility (PDF or Image)',
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Document'),
                  onPressed: _pickDocument,
                ),
                if (_selectedFile != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedFile!.path.split(Platform.pathSeparator).last}',
                    style: const TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold),
                  ),
                ] else if (widget.isEditing &&
                    context
                            .read<ApplicationViewModel>()
                            .myApplication
                            ?.documentUrl !=
                        null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'A document is already uploaded. Selecting a new one will replace it.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
                const SectionHeader(title: 'Declaration'),

                CheckboxListTile(
                  title: const Text(
                    'I confirm that I meet the minimum academic requirements to be a Student Assistant for the selected modules.',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _meetsRequirements,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (val) =>
                      setState(() => _meetsRequirements = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 32),

                // Error message display from ViewModel
                Selector<ApplicationViewModel, String?>(
                  selector: (_, vm) => vm.errorMessage,
                  builder: (_, error, __) {
                    if (error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ErrorMessage(
                        message: error,
                        onDismiss: () => context
                            .read<ApplicationViewModel>()
                            .clearMessages(),
                      ),
                    );
                  },
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: Text(widget.isEditing
                        ? 'Update Application'
                        : 'Submit Application'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
