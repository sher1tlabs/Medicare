import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/main_navigation_shell.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  int _currentStep = 1;
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _dateOfBirth = DateTime(1995, 6, 15);

  // Step 2 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Step 3 Preferences
  bool _currentlyTakesMedicines = true;
  String _preferredReminderTime = '8:00 AM';
  bool _enableNotifications = true;

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_step1FormKey.currentState!.validate()) {
      setState(() => _currentStep = 2);
    }
  }

  void _handleCreateAccount() async {
    if (!_step2FormKey.currentState!.validate()) return;
    setState(() => _currentStep = 3);
  }

  void _finishRegistration() async {
    setState(() => _isLoading = true);

    await LocalStorageService().register(
      name: _nameController.text.trim().isEmpty ? 'Jane Doe' : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? 'user@example.com' : _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
      password: _passwordController.text,
      takesMedicines: _currentlyTakesMedicines,
      preferredReminderTime: _preferredReminderTime,
      notificationsEnabled: _enableNotifications,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                  ),
                  child: const Icon(Icons.check_circle, size: 54, color: Color(0xFF059669)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your account is ready!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to MediCare. We are here to help you stay healthy and never miss a dose.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
                ),
                const Spacer(),
                CustomButton(
                  text: 'Go to Home',
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Step $_currentStep of 3'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _currentStep / 3,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),
              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text('Let us get to know you better', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'e.g. Jane Doe',
            prefixIcon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+1 (555) 000-0000',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 16),
          const Text(
            'Date of Birth',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF64748B)),
                  const SizedBox(width: 12),
                  Text(
                    '${_dateOfBirth.year}-${_dateOfBirth.month.toString().padLeft(2, '0')}-${_dateOfBirth.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Continue',
            onPressed: _goToStep2,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text('Choose a strong password for your account', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'At least 8 characters',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Must be at least 8 characters';
              if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must contain at least one number';
              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Must contain a special character';
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            obscureText: _obscureConfirm,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Password requirements:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 6),
                Text('• At least 8 characters long', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text('• Contains at least one number (0-9)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text('• Contains at least one special character (!@#\$%^&*)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Create Account',
            onPressed: _handleCreateAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Preferences',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        const Text('Customize how MediCare helps manage your regimen', style: TextStyle(color: Color(0xFF64748B))),
        const SizedBox(height: 24),
        const Text(
          'Do you currently take medicines?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Yes')),
                selected: _currentlyTakesMedicines,
                selectedColor: const Color(0xFFCCFBF1),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentlyTakesMedicines ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                ),
                onSelected: (val) => setState(() => _currentlyTakesMedicines = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('No')),
                selected: !_currentlyTakesMedicines,
                selectedColor: const Color(0xFFCCFBF1),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !_currentlyTakesMedicines ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                ),
                onSelected: (val) => setState(() => _currentlyTakesMedicines = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Preferred Reminder Time',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _preferredReminderTime,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.access_time)),
          items: const [
            DropdownMenuItem(value: '7:00 AM', child: Text('7:00 AM - Early Morning')),
            DropdownMenuItem(value: '8:00 AM', child: Text('8:00 AM - Morning')),
            DropdownMenuItem(value: '1:00 PM', child: Text('1:00 PM - Afternoon')),
            DropdownMenuItem(value: '7:00 PM', child: Text('7:00 PM - Evening')),
            DropdownMenuItem(value: '9:00 PM', child: Text('9:00 PM - Night')),
          ],
          onChanged: (v) => setState(() => _preferredReminderTime = v ?? '8:00 AM'),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Medication Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Get sound & vibration alerts when it is time to take pills'),
          value: _enableNotifications,
          activeColor: const Color(0xFF0D9488),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _enableNotifications = v),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Finish Setup',
          isLoading: _isLoading,
          onPressed: _finishRegistration,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _finishRegistration,
            child: const Text('Skip for now', style: TextStyle(color: Color(0xFF64748B))),
          ),
        ),
      ],
    );
  }
}
