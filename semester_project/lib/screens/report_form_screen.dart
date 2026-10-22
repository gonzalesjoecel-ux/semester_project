import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum ReportUiState { idle, loading, success, empty, error }

class ReportItem {
  final String title;
  final String category;
  final String location;
  final String description;

  const ReportItem({
    required this.title,
    required this.category,
    required this.location,
    required this.description,
  });
}

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // USBA: ilisi ug categories sa imong system
  static const _categories = [
    'Facilities',
    'Safety',
    'Network / IT',
    'Cleanliness',
    'Other',
  ];

  String? _category;
  ReportUiState _uiState = ReportUiState.idle;
  bool _simulateFailure = false; // para ma-test ang Error state
  bool _showList = false;

  // Local list ra, DILI database. Ilisan sa REST API sa sunod.
  final List<ReportItem> _reports = [];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------- Validation ----------
  String? _validateTitle(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Report title is required';
    if (value.length < 5) return 'Title must be at least 5 characters';
    return null;
  }

  String? _validateLocation(String? v) {
    if ((v?.trim() ?? '').isEmpty) return 'Location is required';
    return null;
  }

  String? _validateDescription(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Description is required';
    if (value.length < 10) return 'Please enter at least 10 characters';
    return null;
  }

  // ---------- Async submit (simulated) ----------
  Future<void> submitReport() async {
    // Sa Retry, wala na ang Form sa screen, mao nga null-check una
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _showList = false;
      _uiState = ReportUiState.loading;
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_simulateFailure) throw Exception('Simulated failure');
      if (!mounted) return;

      _reports.insert(
        0,
        ReportItem(
          title: _titleController.text.trim(),
          category: _category ?? 'Other',
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      );
      setState(() => _uiState = ReportUiState.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _category = null;
      _showList = false;
      _uiState = ReportUiState.idle;
    });
  }

  void _backToForm() => setState(() {
    _showList = false;
    _uiState = ReportUiState.idle;
  });

  void _viewReports() => setState(() {
    _showList = true;
    _uiState = _reports.isEmpty ? ReportUiState.empty : ReportUiState.success;
  });

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Report'), // USBA kung gusto
        actions: [
          if (_uiState == ReportUiState.idle)
            TextButton(
              onPressed: _viewReports,
              child: const Text('My Reports'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case ReportUiState.idle:
        return _buildForm();
      case ReportUiState.loading:
        return _buildForm();
      case ReportUiState.success:
        return _showList ? _buildList() : _buildSuccess();
      case ReportUiState.empty:
        return _buildEmpty();
      case ReportUiState.error:
        return _buildError();
    }
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _titleController,
              label: 'Report Title',
              validator: _validateTitle,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              label: 'Location',
              validator: _validateLocation,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 4,
              validator: _validateDescription,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate failure (demo only)'),
              value: _simulateFailure,
              onChanged: (v) => setState(() => _simulateFailure = v),
            ),
            const SizedBox(height: 8),
            if (_uiState == ReportUiState.loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Submitting your report...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            AppButton(
              label: _uiState == ReportUiState.loading
                  ? 'Submitting...'
                  : 'Submit Report',
              onPressed: _uiState == ReportUiState.loading
                  ? null
                  : submitReport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Submitting your report...'),
      ],
    ),
  );

  Widget _buildSuccess() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Report submitted (simulated)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'No real database record was saved. This is a local simulation until the REST API is connected.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Submit Another', onPressed: _clearForm),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _viewReports,
          child: const Text('View My Reports'),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'Submission failed',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Something went wrong. Retry, or go back and edit your report.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Retry', onPressed: submitReport),
        const SizedBox(height: 8),
        TextButton(onPressed: _backToForm, child: const Text('Edit Report')),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'No reports yet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Reports you submit will appear here.'),
        const SizedBox(height: 24),
        AppButton(label: 'Create a Report', onPressed: _backToForm),
      ],
    ),
  );

  Widget _buildList() => Column(
    children: [
      Expanded(
        child: ListView.separated(
          itemCount: _reports.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = _reports[i];
            return ListTile(
              leading: const Icon(Icons.report_outlined),
              title: Text(r.title),
              subtitle: Text('${r.category} • ${r.location}\n${r.description}'),
              isThreeLine: true,
            );
          },
        ),
      ),
      AppButton(label: 'New Report', onPressed: _clearForm),
    ],
  );
}
