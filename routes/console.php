<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;

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

