class StorageReport {
  final int totalZones;
  final int totalMaxCapacity;
  final int totalOccupiedCapacity;
  final int totalRemainingCapacity;
  final double usagePercentage;
  final int totalDeliveries;
  final int totalDeliveredQuantity;
  final int alertsCount;

  StorageReport({
    required this.totalZones,
    required this.totalMaxCapacity,
    required this.totalOccupiedCapacity,
    required this.totalRemainingCapacity,
    required this.usagePercentage,
    required this.totalDeliveries,
    required this.totalDeliveredQuantity,
    required this.alertsCount,
  });

  factory StorageReport.fromJson(Map<String, dynamic> json) {
    return StorageReport(
      totalZones: json['totalZones'],
      totalMaxCapacity: json['totalMaxCapacity'],
      totalOccupiedCapacity: json['totalOccupiedCapacity'],
      totalRemainingCapacity: json['totalRemainingCapacity'],
      usagePercentage: (json['usagePercentage'] as num).toDouble(),
      totalDeliveries: json['totalDeliveries'],
      totalDeliveredQuantity: json['totalDeliveredQuantity'],
      alertsCount: json['alertsCount'],
    );
  }
}
