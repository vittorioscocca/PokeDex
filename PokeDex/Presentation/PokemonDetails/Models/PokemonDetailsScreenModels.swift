//
//  PokemonDetailsModels.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation

// MARK: - Azioni per il Coordinator della schermata dei dettagli del Pokémon

/// Enum che rappresenta le azioni specifiche per il coordinator della schermata dei dettagli del Pokémon.
///
/// Attualmente non sono definiti casi specifici, ma l'enum funge da placeholder per eventuali azioni future
/// che il coordinator potrebbe gestire.
enum PokemonDetailsScreenCoordinatorAction { }

// MARK: - Azioni per il ViewModel della schermata dei dettagli del Pokémon

/// Enum che definisce le azioni che il ViewModel della schermata dei dettagli del Pokémon può eseguire.
///
/// In questo esempio, l'unica azione definita è quella di caricare i dettagli del Pokémon.
enum PokemonDetailsScreenViewModelAction {
    /// Azione per avviare il caricamento dei dettagli del Pokémon.
    case loadPokemonDetails
}

// MARK: - Stato della schermata dei dettagli del Pokémon

/// Stato della view per la schermata dei dettagli del Pokémon, conforme al protocollo `BindableState`.
///
/// Questo stato incapsula i dati necessari per visualizzare i dettagli di un Pokémon, utilizzando un
/// oggetto di tipo `PokemonDetailsScreenViewStateBindings` per gestire i binding con la view.
struct PokemonDetailsScreenViewState: BindableState {
    /// Proprietà che contiene le informazioni bindabili della schermata.
    var bindings: PokemonDetailsScreenViewStateBindings
}

// MARK: - Bindings dello stato della schermata dei dettagli del Pokémon

/// Struttura che rappresenta i binding specifici per la schermata dei dettagli del Pokémon.
///
/// Questa struttura contiene tutte le proprietà che possono essere legate alle view per aggiornare dinamicamente
/// l'interfaccia utente. Include dati come il nome, l'immagine, le statistiche, e informazioni per mostrare abilità e mosse,
/// oltre a un eventuale alert.
struct PokemonDetailsScreenViewStateBindings {
    /// Il nome del Pokémon.
    var name: String
    /// L'URL dell'immagine del Pokémon (opzionale).
    var imageURL: URL?
    /// L'altezza del Pokémon.
    var height: Int
    /// Il peso del Pokémon.
    var weight: Int
    /// Un array di stringhe che rappresenta le abilità del Pokémon.
    var abilities: [String]
    /// Un array di stringhe che rappresenta le mosse del Pokémon.
    var moves: [String]
    /// Flag per controllare se le abilità devono essere mostrate.
    var showAbilities: Bool = false
    /// Flag per controllare se le mosse devono essere mostrate.
    var showMoves: Bool = false
    /// Informazioni relative ad un eventuale alert da visualizzare.
    var alertInfo: AlertInfo<PokemonDetailsScreenAlertType>?
    
    /// Inizializza i binding dello stato per la schermata dei dettagli del Pokémon.
    ///
    /// - Parameters:
    ///   - name: Il nome del Pokémon.
    ///   - imageURL: L'URL dell'immagine del Pokémon (opzionale).
    ///   - height: L'altezza del Pokémon.
    ///   - weight: Il peso del Pokémon.
    ///   - abilities: Un array di stringhe contenente le abilità del Pokémon.
    ///   - moves: Un array di stringhe contenente le mosse del Pokémon.
    ///   - alertInfo: Informazioni opzionali per la visualizzazione di un alert.
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

// MARK: - Azioni per la View della schermata dei dettagli del Pokémon

/// Enum che definisce le azioni che la view della schermata dei dettagli del Pokémon può inviare al ViewModel.
///
/// Queste azioni permettono, ad esempio, di alternare la visualizzazione delle abilità o delle mosse del Pokémon.
enum PokemonDetailsScreenViewAction {
    /// Azione per alternare la visualizzazione delle abilità.
    case toggleAbilities
    /// Azione per alternare la visualizzazione delle mosse.
    case toggleMoves
}

// MARK: - Tipologia di Alert per la schermata dei dettagli del Pokémon

/// Enum che rappresenta il tipo di alert che può essere visualizzato nella schermata dei dettagli del Pokémon.
///
/// Attualmente, è definito un solo caso, ma l'enum può essere esteso in futuro per gestire diverse tipologie di alert.
enum PokemonDetailsScreenAlertType {
    /// Caso generico di alert.
    case alert
}
