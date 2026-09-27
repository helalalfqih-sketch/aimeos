<?php
// Isolated, disposable demo only. Never point this deployment at a production DB.
require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();
$db = $app->make('db')->connection();
$db->select('SELECT pg_advisory_lock(260401)');
try {
    $run = function (string $command, array $args = []) use ($kernel): void {
        if ($kernel->call($command, $args + ['--no-interaction' => true]) !== 0) {
            throw new RuntimeException('Demo initialization failed: ' . $command);
        }
    };
    $run('migrate', ['--force' => true]);
    $db->statement('CREATE TABLE IF NOT EXISTS preview_setup (id integer PRIMARY KEY)');
    if (!$db->table('preview_setup')->where('id', 1)->exists()) {
        $run('aimeos:setup', ['--option' => ['setup/default/demo:1']]);
        $run('aimeos:account', [
            'email' => getenv('DEMO_ADMIN_EMAIL'),
            '--password' => getenv('DEMO_ADMIN_PASSWORD'),
            '--super' => true,
            '--admin' => true,
        ]);
        $db->table('preview_setup')->insert(['id' => 1]);
    }
} finally {
    $db->select('SELECT pg_advisory_unlock(260401)');
}
