//
//  PokemonListItemDto.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//
import Foundation

/// Modello che rappresenta un Pokémon nella lista.
struct PokemonListItem: Identifiable, Decodable, Equatable {
    let name: String
    let url: String
    var id: String { name }
    
    /// Calcola l'URL dell'immagine estraendo l'ID dall'URL.
    var imageURL: URL? {
        guard let components = URL(string: url)?.pathComponents,
              let idComponent = components.filter({ !$0.isEmpty }).last else {
            return nil
        }
        return Endpoints.imageURL(for: idComponent)
    }
}
