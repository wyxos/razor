<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('shell_keys', function (Blueprint $table) {
            $table->id();
            $table->string('label');
            $table->string('key')->unique();
            $table->foreignId('server_id')->constrained()->cascadeOnDelete();
            $table->string('user');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('shell_keys');
    }
};
