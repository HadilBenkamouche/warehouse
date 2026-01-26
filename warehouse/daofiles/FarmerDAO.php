<?php
// daofiles/FarmerDAO.php

class FarmerDAO extends BaseDAO {
    public function __construct() {
        parent::__construct('farmer', 'idFarmer');
    }

    // Create farmer profile
    public function create($data) {
        $sql = "INSERT INTO farmer (
                    lastName, firstName, email, phone, farmerCard, 
                    accountStatus, absentCounter, idUser, address, city, state
                ) VALUES (
                    :lastName, :firstName, :email, :phone, :farmerCard,
                    :accountStatus, :absentCounter, :idUser, :address, :city, :state
                )";
        
        return $this->executeQuery($sql, $data);
    }

    // Get farmer with user details
    public function findWithUser($farmerId) {
        $sql = "SELECT f.*, u.username, u.role, u.created_at as userCreatedAt
                FROM farmer f
                JOIN users u ON f.idUser = u.idUser
                WHERE f.idFarmer = :id";
        
        $stmt = $this->executeQuery($sql, [':id' => $farmerId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Get farmer by user ID
    public function findByUserId($userId) {
        $sql = "SELECT f.*, u.username, u.role
                FROM farmer f
                JOIN users u ON f.idUser = u.idUser
                WHERE f.idUser = :userId";
        
        $stmt = $this->executeQuery($sql, [':userId' => $userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Get all farmers with pagination
    public function getAll($status = null, $limit = 50, $offset = 0) {
        $sql = "SELECT f.*, u.username, 
                       (SELECT COUNT(*) FROM appointment a WHERE a.idFarmer = f.idFarmer) as totalAppointments
                FROM farmer f
                JOIN users u ON f.idUser = u.idUser";
        
        $params = [];
        
        if ($status) {
            $sql .= " WHERE f.accountStatus = :status";
            $params[':status'] = $status;
        }
        
        $sql .= " ORDER BY f.idFarmer DESC LIMIT :limit OFFSET :offset";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        
        if ($status) {
            $stmt->bindValue(':status', $status, PDO::PARAM_STR);
        }
        
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Update farmer status
    public function updateStatus($farmerId, $status) {
        $sql = "UPDATE farmer SET accountStatus = :status WHERE idFarmer = :id";
        return $this->executeQuery($sql, [
            ':status' => $status,
            ':id' => $farmerId
        ]);
    }

    // Increment absent counter
    public function incrementAbsentCounter($farmerId) {
        $sql = "UPDATE farmer SET absentCounter = absentCounter + 1 WHERE idFarmer = :id";
        return $this->executeQuery($sql, [':id' => $farmerId]);
    }

    // Reset absent counter
    public function resetAbsentCounter($farmerId) {
        $sql = "UPDATE farmer SET absentCounter = 0 WHERE idFarmer = :id";
        return $this->executeQuery($sql, [':id' => $farmerId]);
    }

    // Search farmers
    public function search($searchTerm, $limit = 20) {
        $sql = "SELECT f.*, u.username
                FROM farmer f
                JOIN users u ON f.idUser = u.idUser
                WHERE f.firstName LIKE :search 
                   OR f.lastName LIKE :search
                   OR f.email LIKE :search
                   OR f.farmerCard LIKE :search
                   OR f.phone LIKE :search
                LIMIT :limit";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':search', "%$searchTerm%", PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Check if farmer card exists
    public function farmerCardExists($farmerCard, $excludeId = null) {
        $sql = "SELECT COUNT(*) as count FROM farmer WHERE farmerCard = :farmerCard";
        $params = [':farmerCard' => $farmerCard];

        if ($excludeId) {
            $sql .= " AND idFarmer != :excludeId";
            $params[':excludeId'] = $excludeId;
        }

        $stmt = $this->executeQuery($sql, $params);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['count'] > 0;
    }

    // Get statistics
    public function getStatistics() {
        $sql = "SELECT 
                    COUNT(*) as totalFarmers,
                    SUM(CASE WHEN accountStatus = 'ACTIVE' THEN 1 ELSE 0 END) as activeFarmers,
                    SUM(CASE WHEN accountStatus = 'PENDING' THEN 1 ELSE 0 END) as pendingFarmers,
                    SUM(CASE WHEN accountStatus = 'SUSPENDED' THEN 1 ELSE 0 END) as suspendedFarmers,
                    SUM(CASE WHEN absentCounter > 0 THEN 1 ELSE 0 END) as farmersWithAbsences
                FROM farmer";
        
        $stmt = $this->executeQuery($sql);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}