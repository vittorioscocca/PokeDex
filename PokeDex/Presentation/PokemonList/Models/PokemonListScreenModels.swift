//
//  Untitled.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

// MARK: - Coordinator

/// Enum che rappresenta le azioni specifiche per il coordinatore della schermata della lista dei Pokémon.
///
/// Attualmente non sono definiti casi specifici, ma l'enum serve come placeholder per eventuali azioni future.
enum PokemonListScreenCoordinatorAction { }

/// Enum che definisce le azioni che il ViewModel della schermata della lista dei Pokémon può inviare.
///
/// - `didShowPokemonDetails`: Indica che i dettagli di un Pokémon sono stati mostrati.
///   - Parameter pokemon: L'oggetto `PokemonListItem` che rappresenta il Pokémon.
enum PokemonListScreenViewModelAction {
    case didShowPokemonDetails(pokemon: PokemonListItem)
}

/// Stato della view per la schermata della lista dei Pokémon, conforme al protocollo `BindableState`.
///
/// Questo stato incapsula tutte le informazioni necessarie per visualizzare la lista dei Pokémon,
/// compreso il conteggio, la lista stessa, le informazioni per la navigazione (next/previous)
/// e eventuali alert.
struct PokemonListScreenViewState: BindableState {
    /// Le proprietà bindabili relative allo stato della view.
    var bindings: PokemonListScreennViewStateBindings
}

/// Struttura che definisce i binding specifici per lo stato della schermata della lista dei Pokémon.
///
/// Include dati quali il conteggio totale, la lista dei Pokémon, gli URL per le pagine successiva e precedente,
/// eventuali informazioni per la visualizzazione di alert e il testo di ricerca inserito dall'utente.
struct PokemonListScreennViewStateBindings {
    /// Il conteggio totale dei Pokémon (opzionale).
    var count: Int?
    /// La lista degli oggetti `PokemonListItem` che rappresentano i Pokémon.
    var pokemonList = [PokemonListItem]()
    /// L'URL della pagina successiva (opzionale).
    var next: String?
    /// L'URL della pagina precedente (opzionale).
    var previous: String?
    /// Informazioni per la visualizzazione di un alert, se necessario.
    var alertInfo: AlertInfo<PokemonListScreenAlertType>?
    /// Il testo di ricerca inserito dall'utente. Inizialmente vuoto.
    var searchText: String = ""
    
    /// Inizializza i binding per la schermata della lista dei Pokémon.
    ///
    /// - Parameters:
    ///   - count: Il conteggio totale dei Pokémon (opzionale).
    ///   - pokemonList: La lista dei Pokémon.
    ///   - next: L'URL della pagina successiva (opzionale).
    ///   - previous: L'URL della pagina precedente (opzionale).
    ///   - alertInfo: Informazioni opzionali per la visualizzazione di un alert.
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

/// Enum che definisce le azioni che la view della schermata della lista dei Pokémon può inviare al ViewModel.
///
/// Le azioni supportate sono:
/// - `showPokemonDetails`: per mostrare i dettagli di un Pokémon specifico.
/// - `loadNextPage`: per caricare la pagina successiva della lista.
enum PokemonListScreenViewAction {
    /// Azione per mostrare i dettagli di un Pokémon.
    /// - Parameter pokemon: L'oggetto `PokemonListItem` del Pokémon selezionato.
    case showPokemonDetails(pokemon: PokemonListItem)
    /// Azione per caricare la pagina successiva della lista dei Pokémon.
    case loadNextPage
}

/// Enum che rappresenta il tipo di alert per la schermata della lista dei Pokémon.
///
/// Attualmente contiene un solo caso, `alert`, che può essere esteso in futuro per gestire ulteriori tipologie di alert.
enum PokemonListScreenAlertType {
    /// Caso generico di alert.
    case alert
}
