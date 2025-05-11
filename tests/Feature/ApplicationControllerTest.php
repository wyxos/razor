<?php

use App\Models\Server;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->actingAs(User::factory()->create());
});

test('it returns the applications index view with server and applications data', function () {
    $server = Server::factory()
        ->hasApplications(5)
        ->create();

    $response = $this->get(route('applications.index', $server));

    $response->assertInertia(fn($page) => $page
        ->component('applications/Index')
        ->has('applications.data', 5)
        ->has('server', fn($data) => $data
            ->where('id', $server->id)
            ->where('label', $server->label)
            ->etc()
        )
    );
});
