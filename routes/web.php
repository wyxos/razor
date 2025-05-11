<?php

use App\Models\Server;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome');
})->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', function () {
        return Inertia::render('Dashboard');
    })->name('dashboard');

    Route::get('servers', function () {
        return Inertia::render('servers/Index');
    })->name('servers.index');

    Route::get('servers/create', function () {
        return Inertia::render('servers/Create');
    })->name('servers.create');

    Route::post('servers', function () {
        // Validate the request
        $validated = request()->validate([
            'label' => 'required|string|max:255',
            'ip' => 'required|ip',
        ]);

        // Create the server
        $server = Server::create([
            'label' => $validated['label'],
            'ip' => $validated['ip']
        ]);

        // Redirect to the server's page
        return redirect()->route('servers.show', $server->id);
    })->name('servers.store');

    // show
    Route::get('servers/{server}', function (Server $server) {
        return Inertia::render('servers/Show', [
            'server' => $server
        ]);
    })->name('servers.show');

    Route::get('applications', function () {
        return Inertia::render('applications/Index');
    })->name('applications.index');
});

require __DIR__.'/settings.php';
require __DIR__.'/auth.php';
