import 'package:flutter/material.dart';
import '../Services/appointment_service.dart';
import '../Models/appointment_model.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Future<List<Appointment>> _appointmentsFuture;
  // الألوان المعتمدة
  final Color primaryBrown = const Color(0xFF4A2C10);
final Color darkBrownBorder = const Color(0xFF2D1B0A);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointmentsFuture = AppointmentService.getScheduledAppointments();
    });
  }

  // دالة موحدة لمعالجة العمليات (Confirm / Cancel)
  void _handleAction(int id, String actionType) async {
    bool success = false;
    
    if (actionType == "confirm") {
      success = await AppointmentService.confirmAttendance(id);
    } else {
      success = await AppointmentService.cancelAppointment(id);
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Action $actionType completed successfully")),
        );
        _loadAppointments(); // تحديث القائمة فوراً
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process action")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1E0),
      appBar: AppBar(
        title: const Text("Scheduled Transactions", 
          style: TextStyle(color: Color(0xFF4A2C10), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: Column(
        children: [
          // البطاقة العلوية المطلوبة
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
              "Scheduled Appointment",
              style: TextStyle(color: Color(0xFFF9F1E0), fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No scheduled appointments."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final app = snapshot.data![index];
                    return _buildActionCard(app);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Appointment app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${app.firstName} ${app.lastName}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusBadge(app.status),
            ],
          ),
          const SizedBox(height: 8),
          Text("Grain: ${app.grainType} | Quantity: ${app.quantity}T"),
          Text("Date: ${app.appointmentDateTime}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // زر الإلغاء المضيء
              _buildGlowingButton("Cancel", const Color(0xFF8D4E33), () {
                _handleAction(app.idAppointment, "cancel");
              }),
              const SizedBox(width: 12),
              // زر التأكيد المضيء
              _buildGlowingButton("Confirm", primaryBrown, () {
                _handleAction(app.idAppointment, "confirm");
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingButton(String text, Color baseColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: darkBrownBorder, width: 2), // محيط أغمق
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryBrown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: TextStyle(color: primaryBrown, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}