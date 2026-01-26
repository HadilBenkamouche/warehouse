import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/appointment_model.dart';

class AppointmentService {
  static const String baseUrl = "http://127.0.0.1/warehouse/services";

  // 📋 جميع المواعيد (Monitor All)
  static Future<List<Appointment>> getAllAppointments() async {
    final response =
        await http.get(Uri.parse("$baseUrl/appointment_monitor.php"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {
        final List data = jsonData['data'];
        return data.map((e) => Appointment.fromJson(e)).toList();
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception("Failed to load appointments");
    }
  }

  // 📅 المواعيد المجدولة فقط
  static Future<List<Appointment>> getScheduledAppointments() async {
    final response =
        await http.get(Uri.parse("$baseUrl/appointment_api.php"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData['success'] == true) {
        final List data = jsonData['data'];
        return data.map((e) => Appointment.fromJson(e)).toList();
      } else {
        throw Exception(jsonData['message']);
      }
    } else {
      throw Exception("Failed to load scheduled appointments");
    }
  }

  // ✅ تأكيد الحضور → COMPLETED
  static Future<bool> confirmAttendance(int idAppointment) async {
    final response = await http.post(
      Uri.parse("$baseUrl/appointment_api.php"),
      body: {
        "idAppointment": idAppointment.toString(),
        "action": "completed", // صحيح حسب الـ API
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  }

  // ❌ إلغاء الموعد → CANCELLED
  static Future<bool> cancelAppointment(int idAppointment) async {
    final response = await http.post(
      Uri.parse("$baseUrl/appointment_api.php"),
      body: {
        "idAppointment": idAppointment.toString(),
        "action": "cancelled", // صحيح حسب الـ API
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  }

  // 🚫 تسجيل غياب يدوي → ABSENT
  static Future<bool> markAbsent(int idAppointment) async {
    final response = await http.post(
      Uri.parse("$baseUrl/appointment_api.php"),
      body: {
        "idAppointment": idAppointment.toString(),
        "action": "absent", // صحيح حسب الـ API
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData['success'] == true;
    } else {
      return false;
    }
  }
}