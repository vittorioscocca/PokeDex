//
//  Untitled.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

/// Enum che definisce le azioni che il ViewModel della schermata della lista dei Pokémon può inviare.
/// - didShowPokemonDetails: Indica che i dettagli di un Pokémon sono stati mostrati, passando l'oggetto `PokemonListItem`.
enum PokemonListScreenViewModelAction {
    case didShowPokemonDetails(pokemon: PokemonListItem)
}

// MARK: - Azioni della View

/// Enum che definisce le azioni che la view della schermata della lista dei Pokémon può inviare al ViewModel.
/// Le azioni supportate sono:
/// - `showPokemonDetails`: per mostrare i dettagli di un Pokémon specifico.
/// - `loadNextPage`: per caricare la pagina successiva della lista.
enum PokemonListScreenViewAction {
    case showPokemonDetails(pokemon: PokemonListItem)
    case loadNextPage
}

// MARK: - Alert

/// Enum che rappresenta il tipo di alert per la schermata della lista dei Pokémon.
/// Attualmente contiene un solo caso, `alert`, che può essere esteso in futuro.
enum PokemonListScreenAlertType {
    case alert
}
