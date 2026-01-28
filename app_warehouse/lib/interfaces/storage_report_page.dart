import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../Models/storage_report_model.dart';
import '../services/storage_report_service.dart';

// الألوان الموحدة التي نستخدمها
const Color primaryBrown = Color(0xFF4A2C10);
const Color darkBrownBorder = Color(0xFF2D1B0A);
const Color accentGold = Color(0xFFE5B96F);

class StorageReportPage extends StatefulWidget {
  const StorageReportPage({super.key});

  @override
  State<StorageReportPage> createState() => _StorageReportPageState();
}

class _StorageReportPageState extends State<StorageReportPage> {
  StorageReport? report;
  bool loading = false;
  String message = '';

  final int idUser = 1;
  final int idWarehouse = 1;

  void _generateReport() async {
    setState(() {
      loading = true;
      message = '';
    });

    try {
      final r = await StorageReportService.generateReport(
        idUser: idUser,
        idWarehouse: idWarehouse,
      );

      setState(() {
        report = r;
        message = 'Report generated successfully';
      });
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String _buildReportParagraph(StorageReport r) {
    return '''
Warehouse Report Summary:

• Total Zones: ${r.totalZones}
• Maximum Capacity: ${r.totalMaxCapacity}
• Occupied Capacity: ${r.totalOccupiedCapacity}
• Remaining Capacity: ${r.totalRemainingCapacity}
• Usage Percentage: ${r.usagePercentage.toStringAsFixed(2)}%
• Total Deliveries: ${r.totalDeliveries}
• Total Delivered Quantity: ${r.totalDeliveredQuantity}
• Alerts: ${r.alertsCount > 0 ? r.alertsCount : "No alerts"}

This report reflects the current storage status.
''';
  }

  Future<void> _exportReport(StorageReport r) async {
    final paragraph = _buildReportParagraph(r);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/storage_report.txt');
    await file.writeAsString(paragraph);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report saved as storage_report.txt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Storage Report', style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBrown),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/kamh.jpg"), // نفس صورة الخلفية
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              // زر توليد التقرير المضيء
              _buildGlowingButton(
                text: loading ? 'Generating...' : 'Generate New Report',
                icon: Icons.analytics,
                baseColor: primaryBrown,
                onTap: loading ? () {} : _generateReport,
              ),
              
              const SizedBox(height: 30),
              
              if (report != null) ...[
                // حاوية النص الأنيقة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6E5).withOpacity(0.9), // لون الكارد الموحد مع شفافية
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: darkBrownBorder.withOpacity(0.2)),boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description, color: primaryBrown),
                          SizedBox(width: 10),
                          Text("Report Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryBrown)),
                        ],
                      ),
                      const Divider(height: 30, color: accentGold),
                      Text(
                        _buildReportParagraph(report!),
                        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // زر التصدير المضيء
                _buildGlowingButton(
                  text: 'Export Report (TXT)',
                  icon: Icons.download_rounded,
                  baseColor: const Color(0xFF8D4E33), // بني فاتح للتمييز
                  onTap: () => _exportReport(report!),
                ),
              ],
              
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء الزر المضيء الموحدة
  Widget _buildGlowingButton({required String text, required IconData icon, required Color baseColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: darkBrownBorder, width: 2), // إطار أغمق
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
