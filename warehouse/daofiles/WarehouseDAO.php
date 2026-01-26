<?php
// daofiles/WarehouseDAO.php

class WarehouseDAO extends BaseDAO {
    public function __construct() {
        parent::__construct('warehouse', 'idWarehouse');
    }

    // Create warehouse
    public function create($data) {
        $sql = "INSERT INTO warehouse (name, location, supportGrainType, contact_phone, contact_email)
                VALUES (:name, :location, :supportGrainType, :contact_phone, :contact_email)";
        
        return $this->executeQuery($sql, $data);
    }

    // Get warehouse with zones
    public function findWithZones($warehouseId) {
        // Get warehouse details
        $sql = "SELECT w.*, 
                       (SELECT COUNT(*) FROM zone_storage z WHERE z.idWarehouse = w.idWarehouse) as totalZones,
                       (SELECT SUM(maxCapacity) FROM zone_storage z WHERE z.idWarehouse = w.idWarehouse) as totalCapacity
                FROM warehouse w
                WHERE w.idWarehouse = :id";
        
        $stmt = $this->executeQuery($sql, [':id' => $warehouseId]);
        $warehouse = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($warehouse) {
            // Get zones for this warehouse
            $zoneSql = "SELECT * FROM zone_storage WHERE idWarehouse = :id ORDER BY grainType";
            $zoneStmt = $this->executeQuery($zoneSql, [':id' => $warehouseId]);
            $warehouse['zones'] = $zoneStmt->fetchAll(PDO::FETCH_ASSOC);
        }
        
        return $warehouse;
    }

    // Get all warehouses with capacity info
    public function getAll($includeZones = false) {
        $sql = "SELECT w.*, 
                       (SELECT COUNT(*) FROM zone_storage z WHERE z.idWarehouse = w.idWarehouse) as zoneCount,
                       (SELECT SUM(maxCapacity) FROM zone_storage z WHERE z.idWarehouse = w.idWarehouse) as totalCapacity,
                       (SELECT SUM(occupiedCapacity) FROM zone_storage z WHERE z.idWarehouse = w.idWarehouse) as occupiedCapacity
                FROM warehouse w
                ORDER BY w.name";
        
        $stmt = $this->executeQuery($sql);
        $warehouses = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if ($includeZones) {
            foreach ($warehouses as &$warehouse) {
                $zoneSql = "SELECT * FROM zone_storage WHERE idWarehouse = :id";
                $zoneStmt = $this->executeQuery($zoneSql, [':id' => $warehouse['idWarehouse']]);
                $warehouse['zones'] = $zoneStmt->fetchAll(PDO::FETCH_ASSOC);
            }
        }
        
        return $warehouses;
    }

    // Get warehouses by grain type
    public function getByGrainType($grainType) {
        $sql = "SELECT DISTINCT w.*
                FROM warehouse w
                JOIN zone_storage z ON w.idWarehouse = z.idWarehouse
                WHERE z.grainType = :grainType
                AND z.zone_status = 'ACTIVE'
                AND (z.maxCapacity - z.occupiedCapacity) > 0
                ORDER BY w.name";
        
        $stmt = $this->executeQuery($sql, [':grainType' => $grainType]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Get available capacity for grain type
    public function getAvailableCapacity($warehouseId, $grainType) {
        $sql = "SELECT SUM(maxCapacity - occupiedCapacity) as availableCapacity
                FROM zone_storage
                WHERE idWarehouse = :warehouseId
                AND grainType = :grainType
                AND zone_status = 'ACTIVE'";
        
        $stmt = $this->executeQuery($sql, [
            ':warehouseId' => $warehouseId,
            ':grainType' => $grainType
        ]);
        
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['availableCapacity'] ?? 0;
    }

    // Update warehouse capacity
    public function updateCapacity($warehouseId) {
        $sql = "UPDATE warehouse w
                SET capacity_total = (
                    SELECT COALESCE(SUM(maxCapacity), 0)
                    FROM zone_storage z
                    WHERE z.idWarehouse = w.idWarehouse
                    AND z.zone_status = 'ACTIVE'
                ),
                capacity_available = (
                    SELECT COALESCE(SUM(maxCapacity - occupiedCapacity), 0)
                    FROM zone_storage z
                    WHERE z.idWarehouse = w.idWarehouse
                    AND z.zone_status = 'ACTIVE'
                )
                WHERE w.idWarehouse = :id";
        
        return $this->executeQuery($sql, [':id' => $warehouseId]);
    }

    // Search warehouses
    public function search($searchTerm, $limit = 20) {
        $sql = "SELECT w.*
                FROM warehouse w
                WHERE w.name LIKE :search
                   OR w.location LIKE :search
                   OR w.supportGrainType LIKE :search
                LIMIT :limit";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':search', "%$searchTerm%", PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}