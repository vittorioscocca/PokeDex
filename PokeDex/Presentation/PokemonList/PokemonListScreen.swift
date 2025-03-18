//
//  PokemonListScreen.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI
import os.log

/// Vista che mostra la lista dei Pokémon.
///
/// La vista utilizza un ViewModel (PokemonListScreenViewModel) per gestire il fetching, la ricerca e la navigazione.
/// La lista viene filtrata in base al testo immesso dall'utente e viene mostrata tramite una List.
/// In caso di errore, viene presentato un alert con un messaggio appropriato.
struct PokemonListScreen: View {
    // MARK: - PROPERTIES
    
    /// ViewModel per la schermata della lista dei Pokémon.
    @ObservedObject var viewModel: PokemonListScreenViewModel
    
    /// Lista filtrata dei Pokémon, basata sul testo di ricerca.
    var filteredList: [PokemonListItem] {
        if viewModel.searchText.isEmpty {
            return viewModel.pokemonList
        } else {
            return viewModel.pokemonList.filter {
                $0.name.lowercased().contains(viewModel.searchText.lowercased())
            }
        }
    }
    
    // MARK: - BODY
    
    var body: some View {
        // Otteniamo la lista filtrata e l'ultimo elemento per il caricamento della pagina successiva.
        let currentList = filteredList
        let lastPokemon = currentList.last
        
        return VStack {
            List(currentList) { pokemon in
                // Visualizza una riga della lista con il PokemonRowView.
                // Quando la riga viene selezionata, viene invocato il callback per mostrare i dettagli.
                PokemonRowView(pokemon: pokemon) {
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Navigating to details for pokemon: \(pokemon.name)"))
                    viewModel.showPokemonDetails(pokemon: pokemon)
                }
                .onAppear {
                    // Se l'ultima cella appare, carica la pagina successiva.
                    if pokemon.id == lastPokemon?.id {
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Last cell appeared, loading next page."))
                        viewModel.loadNextPage()
                    }
                }
            }
            .listStyle(PlainListStyle())
            .accessibilityIdentifier("pokemonList")
        }
        // Presenta un alert in caso di errore.
        .alert(item: $viewModel.alertInfo) { alertInfo in
            Alert(
                title: Text("Attenzione"),
                message: Text("Si è verificato un errore."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle("Pokedex", displayMode: .large)
        // Barra di ricerca per filtrare i Pokémon.
        .searchable(text: $viewModel.searchText, prompt: "Cerca Pokémon...")
    }
}
