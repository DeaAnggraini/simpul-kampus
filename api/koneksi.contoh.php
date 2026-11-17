<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204); // jawaban untuk pemeriksaan awal peramban
    exit;
}

function db(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $pdo = new PDO(
            'mysql:host=localhost;dbname=simpul_kampus;charset=utf8mb4',
            'simpul_app',
            'GANTI_DENGAN_SANDI_ANDA',
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]
        );
    }
    return $pdo;
}

function kirim(int $status, array $data): never
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function bacaJson(): array
{
    $data = json_decode(file_get_contents('php://input') ?: '', true);
    return is_array($data) ? $data : [];
}

function penggunaDariToken(): array
{
    $header = $_SERVER['HTTP_AUTHORIZATION']
        ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
        ?? (array_change_key_case(getallheaders())['authorization'] ?? '');
    if (!preg_match('/^Bearer\s+([a-f0-9]{64})$/', $header, $m)) {
        kirim(401, ['pesan' => 'Silakan masuk terlebih dahulu.']);
    }
    $hash = hash('sha256', $m[1]);
    $q = db()->prepare(
        'SELECT p.id, p.nama, p.peran FROM token t
         JOIN pengguna p ON p.id = t.pengguna_id
         WHERE t.token = ? AND t.kedaluwarsa > NOW()'
    );
    $q->execute([$hash]);
    $pengguna = $q->fetch();
    if (!$pengguna) {
        kirim(401, ['pesan' => 'Sesi berakhir. Silakan masuk kembali.']);
    }
    $pengguna['token_hash'] = $hash;
    return $pengguna;
}