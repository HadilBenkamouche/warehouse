<?php
// daofiles/ReAccessRequestDAO.php

class ReAccessRequestDAO extends BaseDAO {
    public function __construct() {
        parent::__construct('re_access_request', 'idRequest');
    }

    // Create access request
    public function create($data) {
        $sql = "INSERT INTO re_access_request (reason, justification, idFarmer) 
                VALUES (:reason, :justification, :idFarmer)";
        
        return $this->executeQuery($sql, $data);
    }

    // Get request with farmer details
    public function findWithFarmer($requestId) {
        $sql = "SELECT r.*, f.firstName, f.lastName, f.email, f.phone, f.accountStatus
                FROM re_access_request r
                JOIN farmer f ON r.idFarmer = f.idFarmer
                WHERE r.idRequest = :id";
        
        $stmt = $this->executeQuery($sql, [':id' => $requestId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Get all pending requests
    public function getPendingRequests($limit = 100) {
        $sql = "SELECT r.*, f.firstName, f.lastName, f.email, 
                       u.username as farmerUsername
                FROM re_access_request r
                JOIN farmer f ON r.idFarmer = f.idFarmer
                JOIN users u ON f.idUser = u.idUser
                ORDER BY r.idRequest DESC
                LIMIT :limit";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Get requests by farmer
    public function getByFarmer($farmerId) {
        $sql = "SELECT r.* 
                FROM re_access_request r
                WHERE r.idFarmer = :farmerId
                ORDER BY r.idRequest DESC";
        
        $stmt = $this->executeQuery($sql, [':farmerId' => $farmerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Get request statistics
    public function getStatistics() {
        $sql = "SELECT 
                    COUNT(*) as totalRequests,
                    (SELECT COUNT(*) FROM farmer WHERE accountStatus = 'SUSPENDED') as suspendedFarmers
                FROM re_access_request";
        
        $stmt = $this->executeQuery($sql);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}