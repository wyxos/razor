<?php

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

    Route::get('servers', function () {
        return Inertia::render('servers/Index')
            ->with([
                'servers' => Server::orderBy('label')->paginate(10)
            ]);
    })->name('servers.index');

    Route::get('servers/create', function () {
        return Inertia::render('servers/Create');
    })->name('servers.create');

    Route::post('servers', function () {
        // Validate the request
        $validated = request()->validate([
            'label' => 'required|string|max:255',
            'ip' => [
                'nullable',
                Rule::requiredIf(!request()->boolean('external')),
                'ip',
                Rule::unique('servers')
            ],
            'external' => [
                'boolean',
                function ($attribute, $value, $fail) {
                    if (!$value && Server::where('external', false)->exists()) {
                        $fail('Only one non-external server is allowed.');
                    }
                },
            ],
        ]);

        // Create the server
        $server = Server::create([
            'label' => $validated['label'],
            'ip' => $validated['ip'],
            'external' => $validated['external'] ?? false
        ]);

        // Redirect to the server's page
        return redirect()->route('servers.show', $server->id);
    })->name('servers.store');

    Route::delete('servers/{server}', function (Server $server) {
        $server->delete();
        return redirect()->route('servers.index');
    })->name('servers.destroy');

    Route::patch('servers/{server}', function (Server $server) {
        request()->validate([
            'label' => 'required|string|max:255'
        ]);

        $server->update([
            'label' => request('label')
        ]);

        return redirect()->route('servers.show', $server->id);
    })->name('servers.update.label');

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
