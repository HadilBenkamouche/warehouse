class Appointment {
  final int idAppointment;
  final String grainType;
  final int quantity;
  String status; // 🔹 أصبح متغيرًا لتغيير الحالة بعد Confirm / Cancel / Auto Absent
  final String appointmentDateTime;
  final int idFarmer;
  final String firstName;
  final String lastName;
  final String farmerCard;
  final String warehouseName;

  // 🔹 اختياري: تتبع عدد مرات الغياب
  int? farmerAbsentCounter;

  Appointment({
    required this.idAppointment,
    required this.grainType,
    required this.quantity,
    required this.status,
    required this.appointmentDateTime,
    required this.idFarmer,
    required this.firstName,
    required this.lastName,
    required this.farmerCard,
    required this.warehouseName,
    this.farmerAbsentCounter,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      idAppointment: int.parse(json['idAppointment'].toString()),
      grainType: json['grainType'] ?? "",
      quantity: int.parse(json['quantity'].toString()),
      status: json['status'] ?? "SCHEDULED",
      appointmentDateTime: json['appointmentDateTime'] ?? "",
      idFarmer: int.parse(json['idFarmer'].toString()),
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      farmerCard: json['farmerCard'] ?? "",
      warehouseName: json['warehouseName'] ?? "",
      farmerAbsentCounter: json.containsKey('farmerAbsentCounter')
          ? int.parse(json['farmerAbsentCounter'].toString())
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAppointment': idAppointment,
      'grainType': grainType,
      'quantity': quantity,
      'status': status,
      'appointmentDateTime': appointmentDateTime,
      'idFarmer': idFarmer,
      'firstName': firstName,
      'lastName': lastName,
      'farmerCard': farmerCard,
      'warehouseName': warehouseName,
      'farmerAbsentCounter': farmerAbsentCounter ?? 0,
    };
  }
}