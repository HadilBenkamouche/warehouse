<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once __DIR__ . '/../daofiles/AppointmentDAO.php';

$dao = new AppointmentDAO();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {

    // =========================
    // GET → المواعيد المجدولة فقط
    // =========================
    case 'GET':
        $appointments = $dao->getAllScheduledAppointments();
        echo json_encode([
            "success" => true,
            "data" => $appointments
        ]);
        break;

    // =========================
    // POST → تغيير حالة الموعد
    // =========================
    case 'POST':

        $idAppointment = $_POST['idAppointment'] ?? null;
        $action = $_POST['action'] ?? null; 
        // action = completed | cancelled | absent

        if (!$idAppointment || !$action) {
            echo json_encode([
                "success" => false,
                "message" => "Missing parameters"
            ]);
            exit;
        }

        $appointment = $dao->findById($idAppointment);
        if (!$appointment) {
            echo json_encode([
                "success" => false,
                "message" => "Appointment not found"
            ]);
            exit;
        }

        if ($appointment['status'] !== 'SCHEDULED') {
            echo json_encode([
                "success" => false,
                "message" => "Appointment status cannot be changed"
            ]);
            exit;
        }

        // =========
        // COMPLETED
        // =========
        if ($action === 'completed') {
            $dao->updateStatus($idAppointment, 'COMPLETED');
            echo json_encode([
                "success" => true,
                "message" => "Appointment marked as completed"
            ]);
            exit;
        }

        // =========
        // CANCELLED
        // =========
        if ($action === 'cancelled') {
            $dao->updateStatus($idAppointment, 'CANCELLED');
            echo json_encode([
                "success" => true,
                "message" => "Appointment cancelled"
            ]);
            exit;
        }

        // =========
        // ABSENT (يدوي)
        // =========
        if ($action === 'absent') {
            $dao->updateStatus($idAppointment, 'ABSENT');
            echo json_encode([
                "success" => true,
                "message" => "Farmer marked as absent"
            ]);
            exit;
        }

        echo json_encode([
            "success" => false,
            "message" => "Invalid action"
        ]);
        break;

    default:
        echo json_encode([
            "success" => false,
            "message" => "Invalid request method"
        ]);
}