import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/bill_record.dart';
import '../database/database_helper.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<BillRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await DatabaseHelper.instance.getAllBills();
    if (mounted) {
      setState(() {
      _records = records;
      _isLoading = false;
    });
    }
  }

  Future<void> _deleteRecord(BillRecord record) async {
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
            'Are you sure you want to delete the record for ${record.month}?',
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
      await DatabaseHelper.instance.deleteBill(record.id!);
      _loadRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.delete_outline, color: AppColors.error),
            const SizedBox(width: 10),
            Text('Record deleted.', style: GoogleFonts.poppins(fontSize: 13)),
          ]),
          backgroundColor: AppColors.cardAlt,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('📋 Bill History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _records.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  onRefresh: _loadRecords,
                  child: Column(
                    children: [
                      _buildSummaryBar(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          itemCount: _records.length,
                          itemBuilder: (ctx, i) =>
                              _buildListItem(_records[i], i),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryBar() {
    final total = _records.fold(0.0, (s, r) => s + r.finalCost);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Records',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 12)),
            Text('${_records.length} months',
                style: GoogleFonts.orbitron(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ]),
          Container(width: 1, height: 36, color: AppColors.divider),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Total Spent',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 12)),
            Text(ElectricityCalculator.formatRM(total),
                style: GoogleFonts.orbitron(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ]),
        ],
      ),
    );
  }

  Widget _buildListItem(BillRecord record, int index) {
    final colors = [
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.primary,
      AppColors.error,
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key('bill_${record.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.error, size: 28),
        ),
        confirmDismiss: (_) async {
          await _deleteRecord(record);
          return false; // We handle deletion manually
        },
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DetailScreen(record: record)),
            );
            _loadRecords();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                // Month icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      record.month.substring(0, 3).toUpperCase(),
                      style: GoogleFonts.orbitron(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.month,
                          style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${record.units.toStringAsFixed(0)} kWh  •  '
                          '${record.rebatePercent.toStringAsFixed(1)}% rebate',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                // Final cost
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(ElectricityCalculator.formatRM(record.finalCost),
                        style: GoogleFonts.orbitron(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textHint, size: 18),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 20),
          Text('No Records Yet',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Calculate a bill and save it\nto see your history here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.textHint, fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
