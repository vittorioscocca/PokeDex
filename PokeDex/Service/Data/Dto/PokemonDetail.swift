//
//  PokemonDetail.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//
import Foundation

/// Rappresenta una singola abilità.
struct PokemonAbility: Decodable {
    let ability: NamedAPIResource
    let is_hidden: Bool
    let slot: Int
}

/// Rappresenta una mossa.
struct PokemonMove: Decodable {
    let move: NamedAPIResource
    // Per semplificare, qui non includiamo i dettagli di version group
}

/// Rappresenta gli sprite (immagini) del Pokémon.
struct PokemonSprites: Decodable {
    let front_default: String?
    // Puoi aggiungere ulteriori sprite se necessari
}

/// Modello generico per risorse nominate.
struct NamedAPIResource: Decodable {
    let name: String
    let url: String
}
