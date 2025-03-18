//
//  PokemonDetailsModels.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

// MARK: - Azioni del ViewModel

/// Enum che definisce le azioni che il ViewModel della schermata dei dettagli del Pokémon può eseguire.
enum PokemonDetailsScreenViewModelAction {
    case loadPokemonDetails
}

// MARK: - Azioni della View

/// Enum che definisce le azioni che la view della schermata dei dettagli del Pokémon può inviare al ViewModel.
enum PokemonDetailsScreenViewAction {
    case toggleAbilities
    case toggleMoves
}

// MARK: - Alert

/// Enum che rappresenta il tipo di alert per la schermata dei dettagli del Pokémon.
enum PokemonDetailsScreenAlertType {
    case alert
}
