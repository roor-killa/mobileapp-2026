<?php

namespace App\Http\Controllers;

use App\Models\Data;
use Illuminate\Http\Request;

class DataController extends Controller
{
    public function store(Request $request)
    {
        $data = Data::create([
            'content' => $request->input('content')
        ]);

        return response()->json($data, 201);
    }

    public function show($id)
    {
        $data = Data::findOrFail($id);
        return response()->json($data);
    }
}
