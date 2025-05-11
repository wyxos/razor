<?php

namespace App\Http\Controllers;

use App\Models\Server;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class ServerController extends Controller
{
    public function index()
    {
        return Inertia::render('servers/Index')
            ->with([
                'servers' => Server::orderBy('label')->paginate(10)
            ]);
    }

    public function create()
    {
        return Inertia::render('servers/Create');
    }

    public function store(Request $request)
    {
        // Validate the request
        $validated = $request->validate([
            'label' => 'required|string|max:255',
            'ip' => [
                'nullable',
                Rule::requiredIf(!$request->boolean('external')),
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
    }

    public function show(Server $server)
    {
        return Inertia::render('servers/Show', [
            'server' => $server
        ]);
    }

    public function destroy(Server $server)
    {
        $server->delete();
        return redirect()->route('servers.index');
    }

    public function update(Request $request, Server $server)
    {
        $request->validate([
            'label' => 'required|string|max:255'
        ]);

        $server->update([
            'label' => $request->label
        ]);

        return redirect()->route('servers.show', $server->id);
    }


}
