//
//  PokemonDetailsScreenViewModel.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI
import Combine
import os.log

/// ViewModel per la schermata dei dettagli dei Pokémon.
///
/// Questo ViewModel è responsabile di gestire i dati del Pokémon (nome, immagine, statistiche, abilità, mosse)
/// e di eseguire il fetch dei dettagli tramite il servizio API. Inoltre, gestisce l'aggiornamento della UI
/// (mostrando/nascondendo le liste di abilità e mosse) e l'eventuale presentazione di un alert in caso di errore.
class PokemonDetailsScreenViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Il nome del Pokémon.
    @Published var name: String
    
    /// L'URL dell'immagine del Pokémon.
    @Published var imageURL: URL?
    
    /// L'altezza del Pokémon.
    @Published var height: Int = 0
    
    /// Il peso del Pokémon.
    @Published var weight: Int = 0
    
    /// L'elenco delle abilità del Pokémon.
    @Published var abilities: [String] = []
    
    /// L'elenco delle mosse del Pokémon.
    @Published var moves: [String] = []
    
    /// Flag per controllare la visualizzazione delle abilità.
    @Published var showAbilities: Bool = false
    
    /// Flag per controllare la visualizzazione delle mosse.
    @Published var showMoves: Bool = false
    
    /// Informazioni per visualizzare un alert in caso di errore.
    @Published var alertInfo: AlertInfo<PokemonDetailsScreenAlertType>?
    
    // MARK: - Proprietà Private
    
    /// Il servizio API utilizzato per effettuare il fetch dei dettagli del Pokémon.
    private let apiService: APIService
    
    /// Insieme di cancellabili per gestire le sottoscrizioni Combine.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inizializzazione
    
    /// Inizializza il ViewModel per il dettaglio del Pokémon.
    ///
    /// - Parameters:
    ///   - pokemon: Un oggetto `PokemonListItem` contenente i dati iniziali del Pokémon.
    ///   - apiService: Il servizio API da utilizzare per il fetch dei dettagli (default: APIService()).
    init(pokemon: PokemonListItem, apiService: APIService = APIService()) {
        self.name = pokemon.name
        self.imageURL = pokemon.imageURL
        self.apiService = apiService
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Initialized PokemonDetailsViewModel for pokemon: \(pokemon.name)"))
        fetchPokemonDetails(for: pokemon.url)
    }
    
    // MARK: - Metodi Pubblici
    
    /// Effettua il fetch dei dettagli del Pokémon.
    ///
    /// Il metodo:
    /// - Verifica che l'URL fornito sia valido.
    /// - Esegue una chiamata asincrona tramite il metodo `fetchPokemonDetailAsync` di `apiService`.
    /// - In caso di successo, aggiorna le proprietà `height`, `weight`, `abilities` e `moves`.
    /// - In caso di fallimento, gestisce l'errore impostando l'alert.
    ///
    /// - Parameter url: La stringa contenente l'URL per il fetch dei dettagli del Pokémon.
    func fetchPokemonDetails(for url: String) {
        guard let detailURL = URL(string: url) else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error,
                   formattedLogMessage(message: "Invalid URL: \(url)"))
            return
        }
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(endpoint: detailURL.absoluteString, message: "Fetching pokemon details."))
        
        Task {
            switch await self.apiService.fetchPokemonDetailAsync(from: detailURL) {
            case .success(let response):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
                       formattedLogMessage(endpoint: detailURL.absoluteString, message: "Successfully fetched details. Height: \(response.height), Weight: \(response.weight)"))
                await MainActor.run {
                    self.height = response.height
                    self.weight = response.weight
                    self.abilities = response.abilities.map { $0.ability.name }
                    self.moves = response.moves.map { $0.move.name }
                }
            case .failure(let error):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error,
                       formattedLogMessage(endpoint: detailURL.absoluteString, message: "Error fetching details: \(error)"))
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }
    
    /// Alterna la visualizzazione delle abilità.
    ///
    /// Questo metodo inverte il flag `showAbilities` e registra l'azione tramite log.
    func toggleAbilities() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Toggling abilities display."))
        showAbilities.toggle()
    }
    
    /// Alterna la visualizzazione delle mosse.
    ///
    /// Questo metodo inverte il flag `showMoves` e registra l'azione tramite log.
    func toggleMoves() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Toggling moves display."))
        showMoves.toggle()
    }
    
    // MARK: - Gestione Errori
    
    /// Gestisce gli errori verificatisi durante il fetch dei dettagli.
    ///
    /// Registra l'errore tramite log e imposta l'alertInfo per notificare la view.
    ///
    /// - Parameter error: L'errore verificatosi (APIError).
    private func handleError(_ error: APIError) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error,
               formattedLogMessage(message: "Handling error: \(error)"))
        alertInfo = AlertInfo(id: .alert)
    }
}
