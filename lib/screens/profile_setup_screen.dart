import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _nominee1NameController = TextEditingController();
  final _nominee1MobileController = TextEditingController();
  final _nominee2NameController = TextEditingController();
  final _nominee2MobileController = TextEditingController();
  final List<String> _healthIssues = [];
  final _healthIssueController = TextEditingController();
  final List<String> _genders = ['Male', 'Female', 'Other'];
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _nominee1NameController.dispose();
    _nominee1MobileController.dispose();
    _nominee2NameController.dispose();
    _nominee2MobileController.dispose();
    _healthIssueController.dispose();
    super.dispose();
  }

  void _addHealthIssue() {
    if (_healthIssueController.text.isNotEmpty) {
      setState(() {
        _healthIssues.add(_healthIssueController.text);
        _healthIssueController.clear();
      });
    }
  }

  void _removeHealthIssue(int index) {
    setState(() {
      _healthIssues.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.updateUserProfile(
          name: _nameController.text,
          age: int.parse(_ageController.text),
          gender: _selectedGender!,
          mobile: _mobileController.text,
          address: _addressController.text,
          nominee1: {
            'name': _nominee1NameController.text,
            'mobile': _nominee1MobileController.text,
          },
          nominee2: {
            'name': _nominee2NameController.text,
            'mobile': _nominee2MobileController.text,
          },
          healthIssues: _healthIssues,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Health Issues'),
                  items: ['None', 'Diabetes', 'Hypertension', 'Asthma']
                      .map((issue) => DropdownMenuItem(
                            value: issue,
                            child: Text(issue),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: _genders.map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a gender' : null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nominee1NameController,
                  decoration: const InputDecoration(labelText: 'Nominee 1 Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nominee1MobileController,
                  decoration: const InputDecoration(labelText: 'Nominee 1 Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nominee2NameController,
                  decoration: const InputDecoration(labelText: 'Nominee 2 Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nominee2MobileController,
                  decoration: const InputDecoration(labelText: 'Nominee 2 Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save and Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 