//
//  PokemonDetailsModels.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

enum PokemonDetailsScreenCoordinatorAction { }

enum PokemonDetailsScreenViewModelAction {
    case loadPokemonDetails
}

struct PokemonDetailsScreenViewState: BindableState {
    var bindings: PokemonDetailsScreenViewStateBindings
}

struct PokemonDetailsScreenViewStateBindings {
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
         alertInfo: AlertInfo<PokemonDetailsScreenAlertType>? = nil) {
        self.name = name
        self.imageURL = imageURL
        self.height = height
        self.weight = weight
        self.abilities = abilities
        self.moves = moves
        self.alertInfo = alertInfo
    }
}

enum PokemonDetailsScreenViewAction {
    case toggleAbilities
    case toggleMoves
}

enum PokemonDetailsScreenAlertType {
    case alert
}
