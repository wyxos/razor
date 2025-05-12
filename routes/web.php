<?php

use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\ServerController;
use App\Models\Server;
use Illuminate\Support\Facades\Route;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Symfony\Component\Process\Process;

Route::get('/', function () {
    return Inertia::render('Welcome');
})->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', function () {
        return Inertia::render('Dashboard');
    })->name('dashboard');

    Route::get('servers', [ServerController::class, 'index'])->name('servers.index');
    Route::get('servers/create', [ServerController::class, 'create'])->name('servers.create');
    Route::post('servers', [ServerController::class, 'store'])->name('servers.store');
    Route::delete('servers/{server}', [ServerController::class, 'destroy'])->name('servers.destroy');
    Route::patch('servers/{server}', [ServerController::class, 'update'])->name('servers.update.label');
    Route::get('servers/{server}', [ServerController::class, 'show'])->name('servers.show');
    Route::get('servers/{server}/applications', [ApplicationController::class, 'index'])->name('applications.index');

    Route::get('app/update', function () {
        // Disable all known output buffering
        while (ob_get_level() > 0) ob_end_clean();

        header('Content-Type: text/plain');
        header('X-Accel-Buffering: no');
        header('Cache-Control: no-cache');
        header('Transfer-Encoding: chunked'); // allow streaming

        $process = Process::fromShellCommandline('php artisan app:update', base_path());
        $process->setTimeout(null);

        $process->run(function ($type, $buffer) {
            echo $buffer;
            echo str_repeat(' ', 1024); // Force chunk flush
            flush();
        });

        exit;
    });
});

require __DIR__.'/settings.php';
require __DIR__.'/auth.php';
