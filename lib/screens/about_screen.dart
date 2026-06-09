import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open the URL.',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('ℹ️ About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Profile Card
            _buildAppCard(),
            const SizedBox(height: 20),

            // Student Info Card
            _buildStudentCard(),
            const SizedBox(height: 20),

            // How to Use Instructions
            _buildHowToCard(),
            const SizedBox(height: 20),

            // Rate Table
            _buildRateTable(),
            const SizedBox(height: 20),

            // Copyright
            _buildCopyrightCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bg,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 4)
              ],
            ),
            child: const Icon(Icons.bolt, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text('ELEKTRIK BIL',
              style: GoogleFonts.orbitron(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 6),
          Text('Version 1.0.0',
              style:
                  GoogleFonts.poppins(color: AppColors.textHint, fontSize: 12)),
          const SizedBox(height: 12),
          Text(
              'A smart Android application for estimating monthly electricity bills using TNB tariff rates. Features offline database storage, full history management, and an intuitive modern UI.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
          const SizedBox(height: 16),
          // GitHub link
          InkWell(
            onTap: () => _launchUrl(
                'https://github.com/Mrhelper-01/ElectricityBill.git'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, color: AppColors.info, size: 18),
                  const SizedBox(width: 8),
                  Text('github.com/Mrhelper-01/ElectricityBill.git',
                      style: GoogleFonts.poppins(
                          color: AppColors.info,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.info)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              Icons.school_outlined, 'Developer Info', AppColors.accent),
          const SizedBox(height: 16),
          // Photo placeholder
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardAlt,
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5), width: 2),
              ),
              child: ClipOval(
                child: Icon(Icons.person,
                    size: 55, color: AppColors.accent.withValues(alpha: 0.6)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, 'Full Name', 'Zhanyar Dldar Adham',
              AppColors.textPrimary),
          _infoRow(
              Icons.badge_outlined, 'Student ID', 'QIU230-147', AppColors.info),
          _infoRow(Icons.menu_book_outlined, 'Course Code', 'ICT602',
              AppColors.warning),
          _infoRow(Icons.smartphone_outlined, 'Course Name',
              'Mobile Technology', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildHowToCard() {
    final steps = [
      (
        '1',
        '📅 Select Month',
        'Tap the month dropdown and choose the billing month (January – December).'
      ),
      (
        '2',
        '⚡ Enter Units',
        'Type the number of kWh units used this month. Must be between 1 and 1000.'
      ),
      (
        '3',
        '🎁 Set Rebate',
        'Use the slider or type a rebate percentage (0%–5%). Default is 0%.'
      ),
      (
        '4',
        '🔢 Calculate',
        'Tap the CALCULATE button to see Total Charges and Final Cost after rebate.'
      ),
      (
        '5',
        '💾 Save Record',
        'Tap SAVE RECORD to store the result in the local database.'
      ),
      (
        '6',
        '📋 View History',
        'Go to the History tab to see all saved records sorted by month.'
      ),
      (
        '7',
        '✏️ Edit / Delete',
        'Tap any record in History to view details. Use Edit or Delete buttons as needed.'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.help_outline, 'How to Use', AppColors.info),
          const SizedBox(height: 16),
          ...steps.map((s) => _buildStep(s.$1, s.$2, s.$3)),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            child: Center(
              child: Text(num,
                  style: GoogleFonts.orbitron(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc,
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateTable() {
    final rows = [
      ('First 200 kWh', '1 – 200', '21.8 sen'),
      ('Next 100 kWh', '201 – 300', '33.4 sen'),
      ('Next 300 kWh', '301 – 600', '51.6 sen'),
      ('Next 400 kWh', '601 – 1000', '54.6 sen'),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.table_chart_outlined, 'TNB Tariff Rates',
              AppColors.warning),
          const SizedBox(height: 14),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.cardAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  _tableHeader('Block'),
                  _tableHeader('Range (kWh)'),
                  _tableHeader('Rate'),
                ],
              ),
              ...rows.asMap().entries.map((e) => TableRow(
                    decoration: BoxDecoration(
                      color: e.key.isEven
                          ? AppColors.bg.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                    children: [
                      _tableCell(e.value.$1),
                      _tableCell(e.value.$2),
                      _tableCellBold(e.value.$3),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyrightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.copyright, color: AppColors.textHint, size: 20),
          const SizedBox(height: 6),
          Text('© 2026 ElektrikBil App. All rights reserved.',
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.poppins(color: AppColors.textHint, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            'Mobile Technology Assignment – Individual Project by Mr Helper',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ---- Helpers ----
  Widget _sectionTitle(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.poppins(
                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11)),
      );

  Widget _tableCell(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 11)),
      );

  Widget _tableCellBold(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}
