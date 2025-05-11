<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Symfony\Component\Process\Process;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('app/update', function () {
    // Disable all known output buffering
    while (ob_get_level() > 0) ob_end_clean();

    header('Content-Type: text/plain');
    header('Cache-Control: no-cache');
    header('X-Accel-Buffering: no'); // for NGINX
    header('Transfer-Encoding: chunked'); // allow streaming

    $process = Process::fromShellCommandline('php artisan app:update', base_path());
    $process->setTimeout(null);

    $process->run(function ($type, $buffer) {
        echo $buffer;
        echo str_repeat(' ', 1024); // Force chunk flush
        flush();
    });

    exit;
})->middleware('auth:sanctum');
