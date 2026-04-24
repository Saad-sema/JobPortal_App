import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/job_model.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
  TextEditingController();
  final TextEditingController _companyController =
  TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _locationController =
  TextEditingController();
  final TextEditingController _skillsController =
  TextEditingController();
  final TextEditingController _branchesController =
  TextEditingController();
  final TextEditingController _cgpaController =
  TextEditingController();

  String _jobType = 'full-time';
  DateTime? _deadline;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  /// --------------------
  /// Load company name from profile
  /// --------------------
  Future<void> _loadCompanyName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.data()?['companyName'] != null) {
      _companyController.text = doc['companyName'];
    }
  }

  /// --------------------
  /// Pick application deadline
  /// --------------------
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  /// --------------------
  /// Post job to Firestore
  /// --------------------
  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate() ||
        _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final job = JobModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      companyName: _companyController.text.trim(),
      employerId: uid,
      location: _locationController.text.trim(),
      jobType: _jobType,
      requiredSkills: _skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      eligibleBranches: _branchesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      minCgpa:
      double.tryParse(_cgpaController.text.trim()) ?? 0.0,
      status: 'open',
      deadline: Timestamp.fromDate(_deadline!),
    );

    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .add(job.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_titleController, 'Job Title'),
              _field(_companyController, 'Company Name'),
              _field(
                _descriptionController,
                'Job Description',
                maxLines: 4,
              ),
              _field(_locationController, 'Location'),

              /// Job Type
              DropdownButtonFormField<String>(
                value: _jobType,
                decoration: const InputDecoration(
                  labelText: 'Job Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'full-time',
                      child: Text('Full-time')),
                  DropdownMenuItem(
                      value: 'part-time',
                      child: Text('Part-time')),
                  DropdownMenuItem(
                      value: 'internship',
                      child: Text('Internship')),
                  DropdownMenuItem(
                      value: 'remote',
                      child: Text('Remote')),
                ],
                onChanged: (v) =>
                    setState(() => _jobType = v!),
              ),
              const SizedBox(height: 12),

              _field(
                _skillsController,
                'Required Skills (comma separated)',
              ),
              _field(
                _branchesController,
                'Eligible Branches (comma separated)',
              ),
              _field(
                _cgpaController,
                'Minimum CGPA',
                keyboardType: TextInputType.number,
              ),

              /// Deadline
              ListTile(
                title: Text(
                  _deadline == null
                      ? 'Select Application Deadline'
                      : 'Deadline: ${_deadline!.toLocal().toString().split(' ')[0]}',
                ),
                trailing:
                const Icon(Icons.calendar_today),
                onTap: _pickDeadline,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _postJob,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --------------------
  /// Text field helper
  /// --------------------
  Widget _field(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) =>
        v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
