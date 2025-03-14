//
//  PokemonListScreen.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI

struct PokemonListScreen: View {
    // MARK: - PROPERTIES
    @ObservedObject var context: PokemonListScreenViewModel.Context
    
    var filteredPokemonList: [PokemonListItem] {
        if context.searchText.isEmpty {
            return context.pokemonList
        } else {
            return context.pokemonList.filter { $0.name.lowercased().contains(context.searchText.lowercased()) }
        }
    }
    
    // MARK: - BODY
    var body: some View {
        VStack {
            List {
                ForEach(self.filteredPokemonList) { pokemon in
                    PokemonRowView(pokemon: pokemon) {
                        context.send(viewAction: .showPokemonDetails(pokemon: pokemon))
                    }
                    .onAppear {
                        if pokemon == filteredPokemonList.last {
                            context.send(viewAction: .loadNextPage)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .accessibilityIdentifier("pokemonList")
        }
        .alert(item: self.$context.alertInfo)
        .navigationBarTitle("Pokedex", displayMode: .large)
        .searchable(text: $context.searchText, prompt: "Cerca Pokémon...")
    }
    
}
