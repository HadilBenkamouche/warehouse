import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/storage_report_model.dart';

class StorageReportService {
  static const String baseUrl = "http://127.0.0.1/warehouse/services"; // Android Emulator

  // 🔹 إنشاء/جلب تقرير حي (POST)
  static Future<StorageReport> generateReport({
    required int idUser,
    required int idWarehouse,
    String reportType = 'FULL_REPORT',
  }) async {
    final url = Uri.parse("$baseUrl/generate_storage_report.php");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idUser': idUser,
        'idWarehouse': idWarehouse,
        'reportType': reportType,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        return StorageReport.fromJson(data['data']);
      } else if (data['status'] == 'empty') {
        throw Exception("No storage data available for this warehouse");
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Failed to generate report");
    }
  }

  // 🔹 جلب تقارير سابقة (GET)
  static Future<List<Map<String, dynamic>>> getReportHistory({
    required int idWarehouse,
  }) async {
    final url = Uri.parse("$baseUrl/report_history.php?idWarehouse=$idWarehouse");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        final List list = data['data'];
        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Failed to load report history");
    }
  }
}
