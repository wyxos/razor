<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Server extends Model
{
    /** @use HasFactory<\Database\Factories\ServerFactory> */
    use HasFactory;

    protected $guarded = ['id'];

    public function applications(): \Illuminate\Database\Eloquent\Relations\HasMany|Server
    {
        return $this->hasMany(Application::class);
    }
}
