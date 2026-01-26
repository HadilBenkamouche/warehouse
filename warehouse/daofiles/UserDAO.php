<?php
// daofiles/UserDAO.php

class UserDAO extends BaseDAO {
    public function __construct() {
        parent::__construct('users', 'idUser');
    }

    // Create new user
    public function create($username, $password, $role) {
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        $sql = "INSERT INTO users (username, password, role, created_at) 
                VALUES (:username, :password, :role, NOW())";
        
        return $this->executeQuery($sql, [
            ':username' => $username,
            ':password' => $hashedPassword,
            ':role' => $role
        ]);
    }

    // Find user by ID
    public function findById($id) {
        $sql = "SELECT * FROM users WHERE idUser = :id";
        $stmt = $this->executeQuery($sql, [':id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Find user by username
    public function findByUsername($username) {
        $sql = "SELECT * FROM users WHERE username = :username";
        $stmt = $this->executeQuery($sql, [':username' => $username]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Verify credentials
    public function verifyCredentials($username, $password) {
        $user = $this->findByUsername($username);
        
        if (!$user) {
            return false;
        }

        if (password_verify($password, $user['password'])) {
            // Update last login
            $this->updateLastLogin($user['idUser']);
            return $user;
        }

        return false;
    }

    // Update last login
    public function updateLastLogin($userId) {
        $sql = "UPDATE users SET last_login = NOW(), failed_login_attempts = 0 WHERE idUser = :id";
        $this->executeQuery($sql, [':id' => $userId]);
    }

    // Update password
    public function updatePassword($userId, $newPassword) {
        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        $sql = "UPDATE users SET password = :password, password_changed_at = NOW() WHERE idUser = :id";
        return $this->executeQuery($sql, [
            ':password' => $hashedPassword,
            ':id' => $userId
        ]);
    }

    // Get all users by role
    public function getByRole($role, $limit = 100) {
        $sql = "SELECT * FROM users WHERE role = :role LIMIT :limit";
        $stmt = $this->pdo->prepare($sql);
        $stmt->bindValue(':role', $role, PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Check if username exists
    public function usernameExists($username, $excludeId = null) {
        $sql = "SELECT COUNT(*) as count FROM users WHERE username = :username";
        $params = [':username' => $username];

        if ($excludeId) {
            $sql .= " AND idUser != :excludeId";
            $params[':excludeId'] = $excludeId;
        }

        $stmt = $this->executeQuery($sql, $params);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result['count'] > 0;
    }
}