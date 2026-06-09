import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final BillRecord record;
  const DetailScreen({super.key, required this.record});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEditing = false;
  late BillRecord _record;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitsCtrl;
  late TextEditingController _rebateCtrl;
  double _rebateSlider = 0;
  String? _selectedMonth;

  double? _editedTotal;
  double? _editedFinal;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _unitsCtrl =
        TextEditingController(text: _record.units.toStringAsFixed(0));
    _rebateCtrl = TextEditingController(
        text: _record.rebatePercent.toStringAsFixed(1));
    _rebateSlider = _record.rebatePercent;
    _selectedMonth = _record.month;
    _editedTotal = _record.totalCharges;
    _editedFinal = _record.finalCost;
  }

  @override
  void dispose() {
    _unitsCtrl.dispose();
    _rebateCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final units = double.tryParse(_unitsCtrl.text.trim());
    final rebate = double.tryParse(_rebateCtrl.text.trim());
    if (units != null && rebate != null) {
      setState(() {
        _editedTotal = ElectricityCalculator.calculateTotalCharges(units);
        _editedFinal =
            ElectricityCalculator.calculateFinalCost(_editedTotal!, rebate);
      });
    }
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check duplicate month (excluding self)
    final existing =
        await DatabaseHelper.instance.getBillByMonth(_selectedMonth!);
    if (existing != null && existing.id != _record.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'A record for $_selectedMonth already exists.',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.error,
        ));
      }
      return;
    }

    final updated = _record.copyWith(
      month: _selectedMonth,
      units: double.parse(_unitsCtrl.text.trim()),
      rebatePercent: double.parse(_rebateCtrl.text.trim()),
      totalCharges: _editedTotal,
      finalCost: _editedFinal,
    );

    await DatabaseHelper.instance.updateBill(updated);
    setState(() {
      _record = updated;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 10),
          Text('Updated successfully!',
              style: GoogleFonts.poppins(fontSize: 13)),
        ]),
        backgroundColor: AppColors.cardAlt,
      ));
    }
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Text('Delete Record',
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ]),
        content: Text(
            'Delete the record for ${_record.month}? This cannot be undone.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteBill(_record.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(_isEditing ? '✏️ Edit Record' : '📄 Bill Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Delete',
              onPressed: _deleteRecord,
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _unitsCtrl.text = _record.units.toStringAsFixed(0);
                _rebateCtrl.text = _record.rebatePercent.toStringAsFixed(1);
                _rebateSlider = _record.rebatePercent;
                _selectedMonth = _record.month;
                _editedTotal = _record.totalCharges;
                _editedFinal = _record.finalCost;
              }),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isEditing ? _buildEditForm() : _buildViewCard(),
      ),
    );
  }

  // ---- View Mode ----
  Widget _buildViewCard() {
    return Column(
      children: [
        // Month header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.card,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(_record.month,
                  style: GoogleFonts.orbitron(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Electricity Bill Record',
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Detail items
        _detailCard([
          _detailRow(Icons.electric_bolt, 'Units Used',
              '${_record.units.toStringAsFixed(0)} kWh', AppColors.info),
          _divider(),
          _detailRow(Icons.discount_outlined, 'Rebate',
              '${_record.rebatePercent.toStringAsFixed(1)}%',
              AppColors.warning),
          _divider(),
          _detailRow(Icons.receipt_outlined, 'Total Charges',
              ElectricityCalculator.formatRM(_record.totalCharges),
              AppColors.textPrimary),
          _divider(),
          _detailRow(Icons.savings_outlined, 'Rebate Savings',
              '- ${ElectricityCalculator.formatRM(_record.totalCharges - _record.finalCost)}',
              AppColors.warning),
        ]),
        const SizedBox(height: 16),

        // Final cost highlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.2),
                AppColors.card,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FINAL COST',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1)),
                Text('After Rebate',
                    style: GoogleFonts.poppins(
                        color: AppColors.textHint, fontSize: 11)),
              ]),
              Text(ElectricityCalculator.formatRM(_record.finalCost),
                  style: GoogleFonts.orbitron(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 28)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _deleteRecord,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  color: valueColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 1, color: AppColors.divider);

  // ---- Edit Mode ----
  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month
          Text('Month',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedMonth,
            dropdownColor: AppColors.card,
            iconEnabledColor: AppColors.primary,
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              prefixIcon:
                  Icon(Icons.calendar_month, color: AppColors.primary),
            ),
            items: kMonths
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) {
              setState(() => _selectedMonth = v);
            },
            validator: (v) =>
                v == null ? 'Please select a month.' : null,
          ),
          const SizedBox(height: 16),

          // Units
          Text('Units Used (kWh)',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _unitsCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            ],
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              prefixIcon:
                  Icon(Icons.electric_bolt, color: AppColors.primary),
              suffixText: 'kWh',
            ),
            onChanged: (_) => _recalculate(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required.';
              final d = double.tryParse(v.trim());
              if (d == null) return 'Invalid number.';
              if (d < 1 || d > 1000) return 'Must be 1–1000.';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Rebate
          Text('Rebate Percentage',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
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
                      });
                      _recalculate();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 90,
                child: TextFormField(
                  controller: _rebateCtrl,
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
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null && d >= 0 && d <= 5) {
                      setState(() => _rebateSlider = d);
                      _recalculate();
                    }
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final d = double.tryParse(v);
                    if (d == null) return 'Invalid';
                    if (d < 0 || d > 5) return '0–5%';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Live preview
          if (_editedTotal != null && _editedFinal != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Charges',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary, fontSize: 14)),
                      Text(
                          ElectricityCalculator.formatRM(_editedTotal!),
                          style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Final Cost',
                          style: GoogleFonts.poppins(
                              color: AppColors.success, fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text(
                          ElectricityCalculator.formatRM(_editedFinal!),
                          style: GoogleFonts.orbitron(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _saveEdit,
            icon: const Icon(Icons.save_rounded),
            label: const Text('UPDATE RECORD'),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ],
      ),
    );
  }
}
