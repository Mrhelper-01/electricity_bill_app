import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();
  final _unitsCtrl = TextEditingController();
  final _rebateCtrl = TextEditingController(text: '0');
  final _unitsFocus = FocusNode();
  final _rebateFocus = FocusNode();

  String? _selectedMonth;
  double? _totalCharges;
  double? _finalCost;
  bool _hasResult = false;
  bool _isSaving = false;

  // Slider value for rebate
  double _rebateSlider = 0;

  @override
  void dispose() {
    _unitsCtrl.dispose();
    _rebateCtrl.dispose();
    _unitsFocus.dispose();
    _rebateFocus.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final units = double.parse(_unitsCtrl.text.trim());
      final rebate = double.parse(_rebateCtrl.text.trim());
      final total = ElectricityCalculator.calculateTotalCharges(units);
      final final_ = ElectricityCalculator.calculateFinalCost(total, rebate);
      setState(() {
        _totalCharges = total;
        _finalCost = final_;
        _hasResult = true;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_hasResult) return;
    setState(() => _isSaving = true);

    // Check for duplicate month
    final existing =
        await DatabaseHelper.instance.getBillByMonth(_selectedMonth!);
    if (existing != null) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'A record for $_selectedMonth already exists.\nDelete or edit it first.',
                    style: GoogleFonts.poppins(fontSize: 13))),
          ]),
          backgroundColor: AppColors.cardAlt,
        ));
      }
      return;
    }

    final record = BillRecord(
      month: _selectedMonth!,
      units: double.parse(_unitsCtrl.text.trim()),
      rebatePercent: double.parse(_rebateCtrl.text.trim()),
      totalCharges: _totalCharges!,
      finalCost: _finalCost!,
      createdAt: DateTime.now().toIso8601String(),
    );

    final result = await DatabaseHelper.instance.insertBill(record);
    setState(() => _isSaving = false);

    if (mounted) {
      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 10),
            Text('Record saved successfully!',
                style: GoogleFonts.poppins(fontSize: 13)),
          ]),
          backgroundColor: AppColors.cardAlt,
        ));
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save. Please try again.',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedMonth = null;
      _unitsCtrl.clear();
      _rebateCtrl.text = '0';
      _rebateSlider = 0;
      _totalCharges = null;
      _finalCost = null;
      _hasResult = false;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('⚡ Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
            onPressed: _resetForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              _InfoBanner(),
              const SizedBox(height: 20),

              // Month selector
              _buildLabel('📅 Select Month', required: true),
              const SizedBox(height: 8),
              _buildMonthDropdown(),
              const SizedBox(height: 20),

              // Units input
              _buildLabel('⚡ Units Used (kWh)', required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _unitsCtrl,
                focusNode: _unitsFocus,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*')),
                ],
                style: GoogleFonts.poppins(
                    color: AppColors.textPrimary, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Enter 1 – 1000 kWh',
                  prefixIcon:
                      Icon(Icons.electric_bolt, color: AppColors.primary),
                  suffixText: 'kWh',
                  suffixStyle: TextStyle(color: AppColors.textSecondary),
                ),
                onChanged: (_) {
                  if (_hasResult) setState(() => _hasResult = false);
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter units used.';
                  }
                  final d = double.tryParse(v.trim());
                  if (d == null) return 'Enter a valid number.';
                  if (d < 1 || d > 1000) return 'Units must be between 1 and 1000.';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Rebate slider + input
              _buildLabel('🎁 Rebate Percentage', required: false),
              const SizedBox(height: 4),
              _buildRebateRow(),
              const SizedBox(height: 28),

              // Rate Table
              _RateInfoCard(),
              const SizedBox(height: 28),

              // Calculate Button
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('CALCULATE BILL'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Result Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0, 0.15),
                                end: Offset.zero)
                            .animate(anim),
                        child: child)),
                child: _hasResult
                    ? _ResultCard(
                        key: ValueKey('$_totalCharges$_finalCost'),
                        totalCharges: _totalCharges!,
                        finalCost: _finalCost!,
                        onSave: _saveRecord,
                        isSaving: _isSaving,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        if (required)
          Text(' *',
              style: GoogleFonts.poppins(
                  color: AppColors.error, fontSize: 13)),
      ],
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMonth,
      dropdownColor: AppColors.card,
      iconEnabledColor: AppColors.primary,
      style: GoogleFonts.poppins(
          color: AppColors.textPrimary, fontSize: 15),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
        hintText: 'Choose a month...',
      ),
      items: kMonths.map((m) {
        return DropdownMenuItem(
          value: m,
          child: Text(m),
        );
      }).toList(),
      onChanged: (v) {
        setState(() {
          _selectedMonth = v;
          if (_hasResult) _hasResult = false;
        });
      },
      validator: (v) => v == null ? 'Please select a month.' : null,
    );
  }

  Widget _buildRebateRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.divider,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.glow,
                  valueIndicatorColor: AppColors.primary,
                  valueIndicatorTextStyle: GoogleFonts.poppins(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                child: Slider(
                  value: _rebateSlider,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: '${_rebateSlider.toStringAsFixed(1)}%',
                  onChanged: (v) {
                    setState(() {
                      _rebateSlider = v;
                      _rebateCtrl.text = v.toStringAsFixed(1);
                      if (_hasResult) _hasResult = false;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 90,
              child: TextFormField(
                controller: _rebateCtrl,
                focusNode: _rebateFocus,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*'))
                ],
                style: GoogleFonts.poppins(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  suffixText: '%',
                  suffixStyle: TextStyle(color: AppColors.textSecondary),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (v) {
                  final d = double.tryParse(v);
                  if (d != null && d >= 0 && d <= 5) {
                    setState(() {
                      _rebateSlider = d;
                      if (_hasResult) _hasResult = false;
                    });
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final d = double.tryParse(v.trim());
                  if (d == null) return 'Invalid';
                  if (d < 0 || d > 5) return '0–5% only';
                  return null;
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%',
                style: GoogleFonts.poppins(
                    color: AppColors.textHint, fontSize: 11)),
            Text('5%',
                style: GoogleFonts.poppins(
                    color: AppColors.textHint, fontSize: 11)),
          ],
        )
      ],
    );
  }
}

// ---- Info Banner ----
class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Select a month, enter kWh used (1–1000), and optionally set a rebate (0–5%). Tap Calculate to see your bill.',
              style: GoogleFonts.poppins(
                  color: AppColors.info, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Rate Info Card ----
class _RateInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blocks = [
      ('First 200 kWh', '21.8 sen/kWh'),
      ('Next 100 kWh (201–300)', '33.4 sen/kWh'),
      ('Next 300 kWh (301–600)', '51.6 sen/kWh'),
      ('Next 400 kWh (601–1000)', '54.6 sen/kWh'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.table_chart_outlined,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text('TNB Tariff Rates',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 12),
          ...blocks.asMap().entries.map((e) {
            final colors = [
              AppColors.success,
              AppColors.info,
              AppColors.warning,
              AppColors.error
            ];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors[e.key],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(e.value.$1,
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary, fontSize: 12))),
                  Text(e.value.$2,
                      style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---- Result Card ----
class _ResultCard extends StatelessWidget {
  final double totalCharges;
  final double finalCost;
  final VoidCallback onSave;
  final bool isSaving;

  const _ResultCard({
    super.key,
    required this.totalCharges,
    required this.finalCost,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final savings = totalCharges - finalCost;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.15),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.success.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.receipt_long, color: AppColors.success, size: 22),
            const SizedBox(width: 10),
            Text('Calculation Result',
                style: GoogleFonts.poppins(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ]),
          const SizedBox(height: 16),
          _resultRow('Total Charges', ElectricityCalculator.formatRM(totalCharges),
              AppColors.textPrimary),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          _resultRow('Rebate Savings',
              '- ${ElectricityCalculator.formatRM(savings)}', AppColors.warning),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Final Cost',
                  style: GoogleFonts.orbitron(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(ElectricityCalculator.formatRM(finalCost),
                  style: GoogleFonts.orbitron(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.save_rounded),
              label: Text(isSaving ? 'Saving...' : 'SAVE RECORD'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: GoogleFonts.poppins(
                color: valueColor,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
