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
        Schema::create('gold_assets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Contoh: Antam CertiCard 50g, Gelang Rantai Figaro
            $table->enum('category', ['Logam Mulia', 'Perhiasan', 'Tabungan']); // Komposisi portofolio
            $table->decimal('weight', 10, 2); // Berat dalam gram (misal: 50.00)
            $table->decimal('purchase_price', 15, 2); // Harga beli / nilai aset
            $table->string('location')->nullable(); // Misal: Brankas Toko, Simpan Mandiri
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gold_assets');
    }
};