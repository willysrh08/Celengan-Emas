<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GoldAsset extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'category',
        'weight',
        'purchase_price',
        'location',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}