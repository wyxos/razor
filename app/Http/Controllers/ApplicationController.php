<?php

namespace App\Http\Controllers;

use App\Models\Server;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ApplicationController extends Controller
{
    public function index(Server $server)
    {
        return Inertia::render('applications/Index')
            ->with([
                'server' => $server,
                'applications' => $server->applications()->orderBy('name')->paginate(10)
            ]);
    }
}
