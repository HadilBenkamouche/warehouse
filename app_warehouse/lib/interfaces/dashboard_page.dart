import 'package:flutter/material.dart';
import '../Services/appointment_service.dart';
import '../Models/appointment_model.dart';
import 'appointment_list_page.dart';
import 'transaction_page.dart';

// الألوان الموحدة
const Color primaryBrown = Color(0xFF4A2C10);
const Color bgBeige = Color(0xFFF9F1E0);
const Color accentGold = Color(0xFFE5B96F);
const Color darkBrownHeader = Color(0xFF2D1B0A); // بني غامق للبطاقة العلوية

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalAppointments = 0;
  int scheduledCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() async {
    try {
      final all = await AppointmentService.getAllAppointments();
      setState(() {
        totalAppointments = all.length;
        scheduledCount =
            all.where((a) => a.status.toUpperCase() == "SCHEDULED").length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // جعل خلفية الـ Scaffold شفافة لكي تظهر الصورة التي بالخلف
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Admin Dashboard",
            style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchStats,
            icon: const Icon(Icons.refresh, color: primaryBrown),
          )
        ],
      ),
      body: Container(
        // إعداد صورة الخلفية
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/kamh.jpg"), // تأكد من المسار
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🆕 البطاقة العلوية للترحيب والـ Logo
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkBrownHeader.withOpacity(0.9), // بني غامق مع شفافية
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  // مكان الـ Logo
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.eco, color: primaryBrown, size: 40), // استبدلها بـ Image.asset للـ Logo
                  ),
                  const SizedBox(width: 15),
                  // نص الترحيب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Welcome, Admin",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("Pending Tasks: $scheduledCount",
                          style: TextStyle(
                              color: accentGold.withOpacity(0.9),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // أيقونة الـ Account
                  const CircleAvatar(
                    backgroundColor: accentGold,
                    child: Icon(Icons.person, color: primaryBrown),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text("Quick Actions",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBrown)),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(
                    context,
                    "Farmers\nTransactions",
                    Icons.history_edu,
                    accentGold,
                    const TransactionPage(),
                    badge: scheduledCount.toString(),
                  ),
                  _buildMenuCard(
                    context,
                    "Monitor All\nAppointments",
                    Icons.event_note,
                    primaryBrown,
                    const AppointmentListPage(mode: "MONITOR"),
                    badge: totalAppointments.toString(),
                  ),
                  _buildMenuCard(
                    context,
                    "Generate\nReports",
                    Icons.analytics_outlined,
                    const Color(0xFF8D4E33),
                    const Scaffold(body: Center(child: Text("Reports Page"))),
                  ),
                  _buildMenuCard(
                    context,
                    "Manage\nStorage",
                    Icons.warehouse_outlined,
                    const Color(0xFFB08968),
                    const Scaffold(body: Center(child: Text("Storage Page"))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, Widget destination,
      {String? badge}) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination))
            .then((_) => _fetchStats());
      },
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E5).withOpacity(0.85), // شفافية للكارد
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryBrown)),
              ],
            ),
          ),
          if (badge != null && badge != "0")
            Positioned(
              right: 15,
              top: 15,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}