<?php

namespace App\Http\Controllers;

use App\Models\Server;
use Illuminate\Http\Request;

class ApplicationController extends Controller
{
    //
    public function index(Server $server)
    {
        return inertia('applications/Index', [
            'server' => $server,
            'applications' => $server->applications()->orderBy('name')->paginate(10)
        ]);
    }
}
