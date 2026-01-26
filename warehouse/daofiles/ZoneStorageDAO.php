<?php
// daofiles/ZoneStorageDAO.php

class ZoneStorageDAO extends BaseDAO {
    public function __construct() {
        parent::__construct('zone_storage', 'idZone');
    }

    // Create zone
    public function create($data) {
        $sql = "INSERT INTO zone_storage (
                    grainType, maxCapacity, occupiedCapacity, idWarehouse,
                    zone_name, zone_status, temperature_controlled
                ) VALUES (
                    :grainType, :maxCapacity, :occupiedCapacity, :idWarehouse,
                    :zone_name, :zone_status, :temperature_controlled
                )";
        
        return $this->executeQuery($sql, $data);
    }

    // Update zone capacity
    public function updateCapacity($zoneId, $occupiedCapacity) {
        $sql = "UPDATE zone_storage 
                SET occupiedCapacity = :occupiedCapacity 
                WHERE idZone = :id";
        
        return $this->executeQuery($sql, [
            ':occupiedCapacity' => $occupiedCapacity,
            ':id' => $zoneId
        ]);
    }

    // Increment occupied capacity
    public function incrementOccupied($zoneId, $quantity) {
        $sql = "UPDATE zone_storage 
                SET occupiedCapacity = occupiedCapacity + :quantity 
                WHERE idZone = :id 
                AND (occupiedCapacity + :quantity) <= maxCapacity";
        
        $stmt = $this->executeQuery($sql, [
            ':quantity' => $quantity,
            ':id' => $zoneId
        ]);
        
        return $stmt->rowCount() > 0;
    }

    // Decrement occupied capacity
    public function decrementOccupied($zoneId, $quantity) {
        $sql = "UPDATE zone_storage 
                SET occupiedCapacity = GREATEST(0, occupiedCapacity - :quantity)
                WHERE idZone = :id";
        
        return $this->executeQuery($sql, [
            ':quantity' => $quantity,
            ':id' => $zoneId
        ]);
    }

    // Get available zones for grain type
    public function getAvailableZones($warehouseId, $grainType, $requiredCapacity = 0) {
        $sql = "SELECT * FROM zone_storage 
                WHERE idWarehouse = :warehouseId
                AND grainType = :grainType
                AND zone_status = 'ACTIVE'
                AND (maxCapacity - occupiedCapacity) >= :requiredCapacity
                ORDER BY (maxCapacity - occupiedCapacity) DESC";
        
        $stmt = $this->executeQuery($sql, [
            ':warehouseId' => $warehouseId,
            ':grainType' => $grainType,
            ':requiredCapacity' => $requiredCapacity
        ]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Get warehouse capacity summary
    public function getWarehouseCapacitySummary($warehouseId) {
        $sql = "SELECT 
                    grainType,
                    COUNT(*) as zoneCount,
                    SUM(maxCapacity) as totalCapacity,
                    SUM(occupiedCapacity) as occupiedCapacity,
                    SUM(maxCapacity - occupiedCapacity) as availableCapacity
                FROM zone_storage
                WHERE idWarehouse = :warehouseId
                AND zone_status = 'ACTIVE'
                GROUP BY grainType
                ORDER BY grainType";
        
        $stmt = $this->executeQuery($sql, [':warehouseId' => $warehouseId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Update zone status
    public function updateStatus($zoneId, $status) {
        $sql = "UPDATE zone_storage SET zone_status = :status WHERE idZone = :id";
        return $this->executeQuery($sql, [
            ':status' => $status,
            ':id' => $zoneId
        ]);
    }
}