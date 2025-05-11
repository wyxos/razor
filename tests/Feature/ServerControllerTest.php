<?php

use App\Models\Server;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $user = User::factory()->create();
    $this->actingAs($user);
});

test('show method displays the server details', function () {
    $server = Server::factory()->create();

    $response = $this->get(route('servers.show', $server));

    $response->assertOk();
    $response->assertInertia(fn($page) => $page
        ->component('servers/Show')
        ->has('server', fn($data) => $data
            ->where('id', $server->id)
            ->where('label', $server->label)
            ->etc()
        )
    );
});

test('index method displays a list of servers', function () {
    $servers = Server::factory()->count(3)->create()->sortBy('label')->values();

    $response = $this->get(route('servers.index'));

    $response->assertOk();
    $response->assertInertia(fn($page) => $page
        ->component('servers/Index')
        ->has('servers.data', 3)
        ->has('servers.data.0', fn($data) => $data
            ->where('id', $servers[0]->id)
            ->where('label', $servers[0]->label)
            ->etc()
        )
    );
});

test('index method paginates servers correctly', function () {
    Server::factory()->count(15)->create();

    $response = $this->get(route('servers.index'));

    $response->assertOk();
    $response->assertInertia(fn($page) => $page
        ->component('servers/Index')
        ->has('servers.data', 10)
        ->has('servers.current_page')
        ->has('servers.total')
    );
});

test('show method returns 404 for non-existing server', function () {
    $response = $this->get(route('servers.show', 999));

    $response->assertNotFound();
});
