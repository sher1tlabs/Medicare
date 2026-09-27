import 'package:flutter/material.dart';
import '../../models/medicine_info.dart';

class MedicineInfoDetailsScreen extends StatelessWidget {
  final MedicineInfo info;

  const MedicineInfoDetailsScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(info.name),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCFBF1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generic Name: ${info.genericName} • ${info.type}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      info.shortDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Educational Disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Disclaimer: This information is for educational purposes only. Consult a healthcare professional before starting, stopping, or altering your medication regimen.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Common uses
              _buildSectionTitle('Common Uses', Icons.check_circle_outline),
              ...info.commonUses.map((u) => _buildBulletPoint(u)),
              const SizedBox(height: 20),

              // Dosage Info
              _buildSectionTitle('General Dosage Information', Icons.schedule_outlined),
              Padding(
                padding: const EdgeInsets.only(left: 6.0, top: 4.0),
                child: Text(
                  info.dosageInfo,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
                ),
              ),
              const SizedBox(height: 20),

              // Warnings
              _buildSectionTitle('Important Warnings', Icons.error_outline, color: const Color(0xFFDC2626)),
              ...info.warnings.map((w) => _buildBulletPoint(w, isWarning: true)),
              const SizedBox(height: 20),

              // Common side effects
              _buildSectionTitle('Common Side Effects', Icons.healing_outlined),
              ...info.sideEffects.map((s) => _buildBulletPoint(s)),
              const SizedBox(height: 20),

              // Precautions
              _buildSectionTitle('General Precautions', Icons.shield_outlined),
              ...info.precautions.map((p) => _buildBulletPoint(p)),
              const SizedBox(height: 20),

              // Storage
              _buildSectionTitle('Storage Information', Icons.inventory_2_outlined),
              Padding(
                padding: const EdgeInsets.only(left: 6.0, top: 4.0),
                child: Text(
                  info.storageInfo,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color color = const Color(0xFF0D9488)}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color == const Color(0xFFDC2626) ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarning ? const Color(0xFFDC2626) : const Color(0xFF0D9488),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isWarning ? const Color(0xFF991B1B) : const Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
