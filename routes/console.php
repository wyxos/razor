<?php

use Illuminate\Foundation\Inspiring;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
use Symfony\Component\Process\Process;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('app:reset', function () {
    $migrations = File::files(database_path('migrations'));
    $total = count($migrations);
    $keep = 3;
    $rollback = max(0, $total - $keep);

    if ($rollback === 0) {
        $this->info('Nothing to rollback.');
        return;
    }

    $this->warn("Rolling back $rollback migration steps...");
    Artisan::call('migrate:rollback', ['--step' => $rollback], $this->output);

    $this->info("Re-running $rollback migrations...");
    Artisan::call('migrate', [], $this->output);
});

Artisan::command('app:update', function () {
    $this->info('🔄 Updating application...');

    $run = function ($command, $label) {
        $this->comment("→ Running: $label");
        $process = Process::fromShellCommandline($command, base_path());
        $process->setTimeout(300);
        $process->run(function ($type, $buffer) {
            echo $buffer;
        });

        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }
    };

    $run('git pull', 'git pull');
    $run('composer install --no-interaction --prefer-dist --optimize-autoloader', 'composer install');
    $this->call('migrate', ['--force' => true]);
    $this->call('cache:clear');
    $this->call('config:clear');
    $this->call('view:clear');
    $run('npm install && npm run build', 'npm install + build');

    $this->info('✅ Application updated successfully.');
})->purpose('Update the app by pulling latest changes and reinstalling dependencies');

