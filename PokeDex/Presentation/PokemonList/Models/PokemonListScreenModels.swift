//
//  Untitled.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

// MARK: - Coordinator

enum PokemonListScreenCoordinatorAction { }

enum PokemonListScreenViewModelAction {
    case didShowPokemonDetails(pokemon: PokemonListItem)
}

struct PokemonListScreenViewState: BindableState {
    var bindings: PokemonListScreennViewStateBindings
}

struct PokemonListScreennViewStateBindings {
    var count: Int?
    var pokemonList = [PokemonListItem]()
    var next: String?
    var previous: String?
    var alertInfo: AlertInfo<PokemonListScreenAlertType>?
    var searchText: String = ""
    
    init(
        count: Int?,
        pokemonList: [PokemonListItem],
        next: String?,
        previous: String?,
        alertInfo: AlertInfo<PokemonListScreenAlertType>? = nil
    ) {
        self.count = count
        self.pokemonList = pokemonList
        self.next = next
        self.previous = previous
        self.alertInfo = alertInfo
    }
}

enum PokemonListScreenViewAction {
    case showPokemonDetails(pokemon: PokemonListItem)
    case loadNextPage
}

enum PokemonListScreenAlertType {
    case alert
}
