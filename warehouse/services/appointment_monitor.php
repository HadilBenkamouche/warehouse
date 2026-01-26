<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../daofiles/AppointmentDAO.php';

$dao = new AppointmentDAO();

// =======================
// جلب تفاصيل موعد واحد
// =======================
if (isset($_GET['idAppointment'])) {
    $idAppointment = (int) $_GET['idAppointment'];

    $details = $dao->getAppointmentDetails($idAppointment);

    if (!$details) {
        echo json_encode([
            "success" => false,
            "message" => "Appointment not found"
        ]);
        exit;
    }

    echo json_encode([
        "success" => true,
        "data" => $details
    ]);
    exit;
}

// =======================
// جلب كل المواعيد
// =======================
$appointments = $dao->getAllAppointments();

echo json_encode([
    "success" => true,
    "data" => $appointments
]);