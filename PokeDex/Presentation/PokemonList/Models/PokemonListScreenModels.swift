//
//  Untitled.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

// MARK: - Coordinator

/// Enum che rappresenta le azioni specifiche per il coordinator della schermata della lista dei Pokémon.
/// Attualmente non sono definiti casi specifici, ma l'enum serve come placeholder per eventuali azioni future.
enum PokemonListScreenCoordinatorAction { }

/// Enum che definisce le azioni che il ViewModel della schermata della lista dei Pokémon può inviare.
/// - didShowPokemonDetails: Indica che i dettagli di un Pokémon sono stati mostrati, passando l'oggetto `PokemonListItem`.
enum PokemonListScreenViewModelAction {
    case didShowPokemonDetails(pokemon: PokemonListItem)
}

// MARK: - Stato della View

/// Stato della view per la schermata della lista dei Pokémon.
/// Questa struct incapsula tutte le informazioni necessarie per visualizzare la lista,
/// come il conteggio totale, la lista dei Pokémon, i link per le pagine successiva e precedente,
/// eventuali alert e il testo di ricerca.
struct PokemonListScreenViewState {
    /// Il conteggio totale dei Pokémon (opzionale).
    var count: Int?
    /// La lista degli oggetti `PokemonListItem` che rappresentano i Pokémon.
    var pokemonList: [PokemonListItem] = []
    /// L'URL della pagina successiva (opzionale).
    var next: String?
    /// L'URL della pagina precedente (opzionale).
    var previous: String?
    /// Informazioni per la visualizzazione di un alert, se necessario.
    var alertInfo: AlertInfo<PokemonListScreenAlertType>?
    /// Il testo di ricerca inserito dall'utente. Inizialmente vuoto.
    var searchText: String = ""
    
    /// Inizializza lo stato della view con eventuali valori opzionali.
    init(
        count: Int? = nil,
        pokemonList: [PokemonListItem] = [],
        next: String? = nil,
        previous: String? = nil,
        alertInfo: AlertInfo<PokemonListScreenAlertType>? = nil,
        searchText: String = ""
    ) {
        self.count = count
        self.pokemonList = pokemonList
        self.next = next
        self.previous = previous
        self.alertInfo = alertInfo
        self.searchText = searchText
    }
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
