<?php

use App\Http\Controllers\ApplicationController;
use App\Http\Controllers\ServerController;
use App\Models\Server;
use Illuminate\Support\Facades\Route;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

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


});

require __DIR__.'/settings.php';
require __DIR__.'/auth.php';
