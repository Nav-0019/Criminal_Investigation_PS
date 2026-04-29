import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PoliceCaseRegistryScreen extends StatefulWidget {
  @override
  _PoliceCaseRegistryScreenState createState() => _PoliceCaseRegistryScreenState();
}

class _PoliceCaseRegistryScreenState extends State<PoliceCaseRegistryScreen> {
  // Mock Data for the Registry
  final List<Map<String, dynamic>> _cases = [
    {
      'caseId': 'FIR-8912',
      'suspectId': 'SE-891',
      'victims': 4,
      'risk': 'HIGH',
      'status': 'Open',
      'location': 'Bangalore',
    },
    {
      'caseId': 'FIR-8913',
      'suspectId': 'SE-214',
      'victims': 12,
      'risk': 'HIGH',
      'status': 'Under Review',
      'location': 'Mumbai',
    },
    {
      'caseId': 'FIR-8914',
      'suspectId': 'SE-042',
      'victims': 1,
      'risk': 'MEDIUM',
      'status': 'Open',
      'location': 'Delhi',
    },
    {
      'caseId': 'FIR-8915',
      'suspectId': 'SE-771',
      'victims': 2,
      'risk': 'LOW',
      'status': 'Closed',
      'location': 'Chennai',
    },
  ];

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
                    DataColumn(label: Text('Suspect ID')),
                    DataColumn(label: Text('Victims')),
                    DataColumn(label: Text('Risk')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _cases.map((c) {
                    return DataRow(
                      cells: [
                        DataCell(Text(c['caseId'], style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(c['suspectId'])),
                        DataCell(Text(c['victims'].toString())),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRiskColor(c['risk']).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(c['risk'], style: TextStyle(color: _getRiskColor(c['risk']), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        DataCell(
                          Text(c['status'], style: TextStyle(color: _getStatusColor(c['status']), fontWeight: FontWeight.w600)),
                        ),
                        DataCell(Text(c['location'])),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.picture_as_pdf, color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generating FIR-ready PDF for ${c['caseId']}...')));
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            Text('Police Action Center', style: AppTextStyles.subtitle),
            SizedBox(height: 8),
            Text('Quick actions for active investigations.', style: AppTextStyles.caption),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildActionButton(Icons.auto_awesome, 'Auto-Gen Complaint Summary', AppColors.primary)),
                SizedBox(width: 12),
                Expanded(child: _buildActionButton(Icons.file_download, 'Export to Cyber Portal', AppColors.medAmberDark)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildActionButton(Icons.link, 'Entity Intelligence (Graph)', Colors.purple)),
                SizedBox(width: 12),
                Expanded(child: _buildActionButton(Icons.notifications_active, 'Broadcast High-Risk Alert', AppColors.highRed)),
              ],
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action: $label initiated.')));
      },
      child: Container(
        height: 100,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
