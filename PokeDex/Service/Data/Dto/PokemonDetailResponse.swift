//
//  PokemonDetailResponse.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation

/// Risposta dell’API per la lista dei Pokémon.
struct PokemonDetailResponse: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let abilities: [PokemonAbility]
    let moves: [PokemonMove]
    let sprites: PokemonSprites
}
