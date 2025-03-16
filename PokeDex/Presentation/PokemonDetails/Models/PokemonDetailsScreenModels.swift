//
//  PokemonDetailsModels.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

// MARK: - Coordinator

/// Enum che rappresenta le azioni specifiche per il coordinator della schermata dei dettagli del Pokémon.
/// Attualmente non sono definiti casi specifici, ma l'enum serve come placeholder per eventuali azioni future.
enum PokemonDetailsScreenCoordinatorAction { }

// MARK: - Azioni del ViewModel

/// Enum che definisce le azioni che il ViewModel della schermata dei dettagli del Pokémon può eseguire.
enum PokemonDetailsScreenViewModelAction {
    case loadPokemonDetails
}

// MARK: - Stato della View

/// Stato della view per la schermata dei dettagli del Pokémon.
/// Questa struct incapsula tutti i dati necessari per visualizzare i dettagli del Pokémon.
struct PokemonDetailsScreenViewState {
    var name: String
    var imageURL: URL?
    var height: Int
    var weight: Int
    var abilities: [String]
    var moves: [String]
    var showAbilities: Bool = false
    var showMoves: Bool = false
    var alertInfo: AlertInfo<PokemonDetailsScreenAlertType>?
    
    init(name: String,
         imageURL: URL?,
         height: Int,
         weight: Int,
         abilities: [String],
         moves: [String],
         showAbilities: Bool = false,
         showMoves: Bool = false,
         alertInfo: AlertInfo<PokemonDetailsScreenAlertType>? = nil) {
        self.name = name
        self.imageURL = imageURL
        self.height = height
        self.weight = weight
        self.abilities = abilities
        self.moves = moves
        self.showAbilities = showAbilities
        self.showMoves = showMoves
        self.alertInfo = alertInfo
    }
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
