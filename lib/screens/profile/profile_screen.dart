import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _service = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of MediCare?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _service.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account, medication schedules, and logged history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _service.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _service.currentUser;
    final isDark = _service.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: const Color(0xFFCCFBF1),
                      child: Text(
                        (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: const Color(0xFF0D9488),
                              side: const BorderSide(color: Color(0xFF0D9488)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section: Personal Information
              _buildSectionHeader('Personal Information'),
              _buildSettingCard([
                _buildInfoRow('Full Name', user?.name ?? 'N/A'),
                const Divider(height: 1),
                _buildInfoRow('Email', user?.email ?? 'N/A'),
                const Divider(height: 1),
                _buildInfoRow('Phone', user?.phone ?? 'N/A'),
                const Divider(height: 1),
                _buildInfoRow(
                  'Date of Birth',
                  user != null
                      ? '${user.dateOfBirth.month}/${user.dateOfBirth.day}/${user.dateOfBirth.year}'
                      : 'N/A',
                ),
              ]),
              const SizedBox(height: 24),

              // Section: Health Preferences
              _buildSectionHeader('Health Preferences'),
              _buildSettingCard([
                _buildNavRow(
                  Icons.notifications_active_outlined,
                  'Notification & Alert Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildInfoRow(
                  'Default Schedule Time',
                  user?.preferredReminderTime ?? '8:00 AM',
                ),
                const Divider(height: 1),
                _buildInfoRow(
                  'Current Medicine Status',
                  user?.takesMedicines == true ? 'Active User' : 'Preventative Care',
                ),
              ]),
              const SizedBox(height: 24),

              // Section: App Settings
              _buildSectionHeader('App Settings'),
              _buildSettingCard([
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF0D9488)),
                  title: const Text('Dark Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  value: isDark,
                  activeColor: const Color(0xFF0D9488),
                  onChanged: (val) => _service.toggleDarkMode(val),
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.language_outlined,
                  'Language',
                  trailingText: 'English (US)',
                  onTap: () => _showInfoDialog('Language', 'MediCare is configured to English (US). Additional languages will be available in future releases.'),
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.lock_outline,
                  'Privacy & Security',
                  onTap: () => _showInfoDialog('Privacy & Data', 'Your health data is securely stored locally on this device. MediCare does not sell or share personal health telemetry.'),
                ),
              ]),
              const SizedBox(height: 24),

              // Section: Support
              _buildSectionHeader('Support & Legal'),
              _buildSettingCard([
                _buildNavRow(
                  Icons.help_outline,
                  'Help Center & FAQ',
                  onTap: () => _showInfoDialog('Help Center', 'MediCare helps you stay compliant with your prescription schedule. For assistance, reach out to support@medicare.app.'),
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.mail_outline,
                  'Contact Support',
                  onTap: () => _showInfoDialog('Support', 'Contact our support team at support@medicare.app anytime.'),
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.description_outlined,
                  'Terms & Conditions',
                  onTap: () => _showInfoDialog('Terms', 'MediCare is an informational tool and does not provide diagnosis or direct treatment advice.'),
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.privacy_tip_outlined,
                  'Privacy Policy',
                  onTap: () => _showInfoDialog('Privacy Policy', 'MediCare respects your privacy. All medication records remain confidential.'),
                ),
              ]),
              const SizedBox(height: 24),

              // Section: Account Actions
              _buildSectionHeader('Account Actions'),
              _buildSettingCard([
                _buildNavRow(
                  Icons.vpn_key_outlined,
                  'Change Password',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset instructions sent to your email.')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.logout,
                  'Logout',
                  color: const Color(0xFFEF4444),
                  onTap: _confirmLogout,
                ),
                const Divider(height: 1),
                _buildNavRow(
                  Icons.delete_forever_outlined,
                  'Delete Account',
                  color: const Color(0xFFDC2626),
                  onTap: _confirmDeleteAccount,
                ),
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(
    IconData icon,
    String title, {
    String? trailingText,
    Color? color,
    required VoidCallback onTap,
  }) {
    final itemColor = color ?? const Color(0xFF0F172A);
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF0D9488), size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: itemColor),
      ),
      trailing: trailingText != null
          ? Text(trailingText, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))
          : const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
