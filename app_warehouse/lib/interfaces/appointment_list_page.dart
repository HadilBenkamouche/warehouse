import 'package:flutter/material.dart';
import '../Services/appointment_service.dart';
import '../Models/appointment_model.dart';

class AppointmentListPage extends StatefulWidget {
  final String mode;
  const AppointmentListPage({super.key, required this.mode});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  String selectedFilter = "ALL";
  List<Appointment> allAppointments = [];
  List<Appointment> filteredAppointments = [];
  bool isLoading = true;

  // الألوان الموحدة
  final Color primaryBrown = const Color(0xFF4A2C10);
 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // استخدام الدالة المخصصة للمراقبة من الـ Service
  void _loadData() async {
    try {
      final data = await AppointmentService.getAllAppointments();
      setState(() {
        allAppointments = data;
        filteredAppointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      if (filter == "ALL") {
        filteredAppointments = allAppointments;
      } else {
        // تصفية بناءً على الحالة المرتجعة من المودل
        filteredAppointments = allAppointments
            .where((a) => a.status.toUpperCase() == filter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1E0),
      appBar: AppBar(
        title: const Text("Monitor Appointments",
            style: TextStyle(color: Color(0xFF4A2C10), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // البطاقة العلوية (Header Card)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBrown,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: primaryBrown.withOpacity(0.3), blurRadius: 10)
              ],
            ),
            child: const Text(
              "All Appointments History",
              style: TextStyle(
                  color: Color(0xFFF9F1E0),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // شريط الفلاتر التفاعلي
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ["ALL", "SCHEDULED", "COMPLETED", "CANCELLED", "ABSENT"]
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: selectedFilter == f,
                          onSelected: (_) => _applyFilter(f),
                          selectedColor: primaryBrown,
                          labelStyle: TextStyle(
                              color: selectedFilter == f
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
            ),
          ),Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                    ? const Center(child: Text("No records found for this filter."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final app = filteredAppointments[index];
                          return _buildMonitorCard(app);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorCard(Appointment app) {
    return Card(
      color: const Color(0xFFFFF6E5),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text("${app.firstName} ${app.lastName}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Grain: ${app.grainType} | Qty: ${app.quantity}T"),
            Text("Date: ${app.appointmentDateTime}",
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusText(app.status),
          ],
        ),
      ),
    );
  }

  // دالة لتلوين نص الحالة حسب نوعها
  Widget _buildStatusText(String status) {
    Color statusColor;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = Colors.green.shade700;
        break;
      case 'CANCELLED':
        statusColor = Colors.red.shade700;
        break;
      case 'ABSENT':
        statusColor = Colors.orange.shade800;
        break;
      case 'SCHEDULED':
        statusColor = primaryBrown;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Text(
      status,
      style: TextStyle(
        color: statusColor,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }
}
