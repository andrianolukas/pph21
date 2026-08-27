<?php

use Illuminate\Support\Facades\Route;

Route::inertia('/', 'Cv')->name('home');
Route::inertia('/pph21', 'Welcome')->name('pph21');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::inertia('dashboard', 'Dashboard')->name('dashboard');
});

require __DIR__.'/settings.php';
