//
//  PokemonListResponse.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//
import Foundation

/// Risposta dell’API per la lista dei Pokémon.
struct PokemonListResponse: Decodable {
    let count: Int?
    let next: String?
    let previous: String?
    let results: [PokemonListItem]?
}
