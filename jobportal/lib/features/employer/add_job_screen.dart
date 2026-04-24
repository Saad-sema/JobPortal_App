import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/job_model.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _branchesController = TextEditingController();
  final _cgpaController = TextEditingController();

  String _jobType = 'full-time';
  DateTime? _deadline;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null && data['companyName'] != null) {
      _companyController.text = data['companyName'];
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981),
              surface: Color(0xFF0A0E1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate() || _deadline == null) return;

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
      minCgpa: double.tryParse(_cgpaController.text) ?? 0.0,
      status: 'open',
      deadline: Timestamp.fromDate(_deadline!),
    );

    await FirebaseFirestore.instance.collection('jobs').add(job.toMap());

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: _backBtn(context),
        title: const Text(
          'Post Job',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: _divider(),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF1A1F38),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field(_titleController, 'Job Title', Icons.title_rounded),
                _field(_companyController, 'Company', Icons.business),
                _field(
                  _descriptionController,
                  'Description',
                  Icons.description,
                  maxLines: 4,
                ),
                _field(_locationController, 'Location', Icons.location_on),

                _dropdown(),

                _field(
                  _skillsController,
                  'Skills (comma separated)',
                  Icons.code,
                ),
                _field(
                  _branchesController,
                  'Eligible Branches',
                  Icons.school,
                ),
                _field(
                  _cgpaController,
                  'Minimum CGPA',
                  Icons.grade,
                  keyboardType: TextInputType.number,
                ),

                _deadlineTile(),

                const SizedBox(height: 30),

                _submitBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _backBtn(BuildContext context) => IconButton(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
    ),
    onPressed: () => Navigator.pop(context),
  );

  PreferredSize _divider() => PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );

  Widget _field(
      TextEditingController c,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _glass(
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF94A3B8), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: c,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: label,
                      hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: _glass(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _jobType,
          isExpanded: true,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.white.withOpacity(0.7)),
          items: const [
            DropdownMenuItem(value: 'full-time', child: Text('Full Time')),
            DropdownMenuItem(value: 'part-time', child: Text('Part Time')),
            DropdownMenuItem(value: 'remote', child: Text('Remote')),
            DropdownMenuItem(
                value: 'internship', child: Text('Internship')),
          ],
          onChanged: (v) => setState(() => _jobType = v!),
        ),
      ),
    ),
  );

  Widget _deadlineTile() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: _glass(
      child: ListTile(
        leading: const Icon(Icons.calendar_today,
            color: Color(0xFF94A3B8)),
        title: Text(
          _deadline == null
              ? 'Select Deadline'
              : _deadline!.toLocal().toString().split(' ')[0],
          style: const TextStyle(color: Colors.white),
        ),
        trailing:
        const Icon(Icons.chevron_right, color: Colors.white),
        onTap: _pickDeadline,
      ),
    ),
  );

  Widget _submitBtn() => ElevatedButton(
    onPressed: _loading ? null : _postJob,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF10B981),
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: SizedBox(
      width: double.infinity,
      child: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Post Job',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _glass({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: child,
  );
}
