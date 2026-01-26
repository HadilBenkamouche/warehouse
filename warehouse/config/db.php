<?php

class DBHelper {
    private static $host = "localhost";
    private static $db   = "warehouse_db";
    private static $user = "root";
    private static $pass = "";
    private static $charset = "utf8mb4";
    private static $port = 3308;

    public static function connect() {
        $dsn = "mysql:host=".self::$host.";port=".self::$port.";dbname=".self::$db.";charset=".self::$charset;
        try {
            $pdo = new PDO($dsn, self::$user, self::$pass);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $pdo;
        } catch (PDOException $e) {
            die("Connection failed: " . $e->getMessage());
        }
    }
}