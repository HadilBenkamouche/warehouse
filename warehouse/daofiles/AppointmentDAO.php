<?php
require_once __DIR__ . '/../config/db.php';

class AppointmentDAO {

    private $conn;

    public function __construct() {
        $this->conn = DBHelper::connect();
    }

    // 🔄 تحديث تلقائي للمواعيد الغائبة
    private function autoUpdateAbsentAppointments() {
        $sql = "
            UPDATE appointment a
            JOIN farmer f ON a.idFarmer = f.idFarmer
            SET 
                a.status = 'ABSENT',
                f.absentCounter = f.absentCounter + 1
            WHERE 
                a.status = 'SCHEDULED'
                AND a.appointmentDateTime < NOW()
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
    }

    // جلب كل المواعيد المجدولة
    public function getAllScheduledAppointments() {

        // ⬅️ مهم
        $this->autoUpdateAbsentAppointments();

        $sql = "
        SELECT 
            a.idAppointment,
            a.grainType,
            a.quantity,
            a.status,
            a.appointmentDateTime,
            f.idFarmer,
            f.firstName,
            f.lastName,
            f.farmerCard,
            w.name AS warehouseName
        FROM appointment a
        JOIN farmer f ON a.idFarmer = f.idFarmer
        JOIN warehouse w ON a.idWarehouse = w.idWarehouse
        WHERE a.status = 'SCHEDULED'
        ORDER BY a.appointmentDateTime ASC
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // جلب كل المواعيد بدون فلترة
    public function getAllAppointments() {

        // ⬅️ مهم
        $this->autoUpdateAbsentAppointments();

        $sql = "
        SELECT
            a.idAppointment,
            a.grainType,
            a.quantity,
            a.status,
            a.appointmentDateTime,
            f.idFarmer,
            f.firstName,
            f.lastName,
            f.farmerCard,
            w.name AS warehouseName
        FROM appointment a
        JOIN farmer f ON a.idFarmer = f.idFarmer
        JOIN warehouse w ON a.idWarehouse = w.idWarehouse
        ORDER BY a.appointmentDateTime DESC
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // جلب موعد حسب ID
    public function findById($idAppointment) {
        $stmt = $this->conn->prepare(
            "SELECT * FROM appointment WHERE idAppointment = ?"
        );
        $stmt->execute([$idAppointment]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // تحديث حالة الموعد (COMPLETED / CANCELLED)
    public function updateStatus($idAppointment, $status) {
        $stmt = $this->conn->prepare(
            "UPDATE appointment SET status = ? WHERE idAppointment = ?"
        );
        return $stmt->execute([$status, $idAppointment]);
    }

    // جلب تفاصيل موعد واحد
    public function getAppointmentDetails($idAppointment) {
        $sql = "
        SELECT
            a.idAppointment,
            a.grainType,
            a.quantity,
            a.status,
            a.appointmentDateTime,
            f.idFarmer,
            f.firstName,
            f.lastName,
            f.phone,
            f.email,
            f.farmerCard,
            f.accountStatus,
            w.name AS warehouseName,
            w.location AS warehouseLocation
        FROM appointment a
        JOIN farmer f ON a.idFarmer = f.idFarmer
        JOIN warehouse w ON a.idWarehouse = w.idWarehouse
        WHERE a.idAppointment = ?
        ";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute([$idAppointment]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}