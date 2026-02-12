<?php

namespace App\Http\Controllers;

use App\Models\Item;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    // POST /api/items
    public function store(Request $request)
    {
        $item = Item::create([
            'title' => $request->title,
            'content' => $request->content
        ]);

        return response()->json($item, 201);
    }

    // GET /api/items
    public function index()
    {
        return response()->json(Item::all());
    }
}
