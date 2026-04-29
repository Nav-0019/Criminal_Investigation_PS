import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/history_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PoliceCaseRegistryScreen extends StatefulWidget {
  @override
  _PoliceCaseRegistryScreenState createState() => _PoliceCaseRegistryScreenState();
}

class _PoliceCaseRegistryScreenState extends State<PoliceCaseRegistryScreen> {
  List<HistoryItem> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allItems = await HistoryService.getHistory();
    // Only show explicitly reported cases that are High or Medium risk
    final filtered = allItems.where((i) => i.isReported && (i.risk == 'HIGH' || i.risk == 'MEDIUM')).toList();
    if (mounted) {
      setState(() {
        _cases = filtered;
      });
    }
  }

  Color _getRiskColor(String risk) {
    if (risk == 'HIGH') return AppColors.highRed;
    if (risk == 'MEDIUM') return AppColors.medAmber;
    return AppColors.lowGreen;
  }

  Color _getStatusColor(String status) {
    if (status == 'Open') return AppColors.highRed;
    if (status == 'Under Review') return AppColors.medAmber;
    return AppColors.lowGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Digital FIR Case Registry', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refreshing case registry...')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Case Files', style: AppTextStyles.subtitle),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMid),
                  dataTextStyle: TextStyle(color: AppColors.textDark),
                  columns: const [
                    DataColumn(label: Text('Case ID')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Risk')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _cases.map((c) {
                    final dateObj = DateTime.fromMillisecondsSinceEpoch(c.timestamp);
                    final caseId = 'FIR-${c.timestamp.toString().length > 5 ? c.timestamp.toString().substring(5) : c.timestamp}';
                    final dateStr = DateFormat('MMM d, yyyy').format(dateObj);
                    final typeStr = c.keyword.isNotEmpty ? c.keyword : 'Unknown';
                    final locStr = c.location.isNotEmpty ? c.location : 'Unknown';

                    return DataRow(
                      cells: [
                        DataCell(Text(caseId, style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(dateStr)),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRiskColor(c.risk).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(c.risk, style: TextStyle(color: _getRiskColor(c.risk), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        DataCell(Text(typeStr, style: TextStyle(color: AppColors.textMid))),
                        DataCell(Text(locStr)),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.picture_as_pdf, color: AppColors.primary),
                            onPressed: () => _generateFIRPdf(c, caseId, dateStr, typeStr, locStr),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _generateFIRPdf(HistoryItem c, String caseId, String dateStr, String typeStr, String locStr) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('NammaShield Incident Report (Police Copy)', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Reference ID: $caseId', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Date Logged: $dateStr', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              pw.Text('Incident Details:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Risk Level: ${c.risk}'),
              pw.Text('Detected Type: $typeStr'),
              pw.Text('Location: $locStr'),
              pw.SizedBox(height: 30),
              pw.Text('Raw Data Dump:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(c.fullData.toString(), style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 30),
              pw.Text('This is an auto-generated preliminary report by NammaShield to assist law enforcement and fraud prevention units.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'NammaShield_FIR_$caseId.pdf');
  }
}
