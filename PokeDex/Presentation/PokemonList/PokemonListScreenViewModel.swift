//
//  PokemonListScreenViewModel.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI
import Combine
import os.log

/// ViewModel per la schermata della lista dei Pokémon.
///
/// Questo ViewModel si occupa di:
/// - Effettuare il fetch della lista dei Pokémon tramite il servizio API.
/// - Gestire la ricerca filtrata in base al testo inserito.
/// - Fornire un callback per notificare al coordinator la richiesta di visualizzazione dei dettagli di un Pokémon.
/// - Gestire l'aggiornamento dello stato e l'eventuale presentazione di un alert in caso di errore.
class PokemonListScreenViewModel: ObservableObject {
    
    // MARK: - Proprietà Pubbliche
    
    /// Lista dei Pokémon ottenuta dalla chiamata API.
    @Published var pokemonList: [PokemonListItem] = []
    
    /// Testo di ricerca per filtrare la lista dei Pokémon.
    @Published var searchText: String = ""
    
    /// Informazioni per visualizzare un alert in caso di errore.
    @Published var alertInfo: AlertInfo<PokemonListScreenAlertType>?
    
    // MARK: - Proprietà Private
    
    /// URL della pagina successiva per il caricamento della lista.
    private var nextURL: String?
    
    /// Il servizio API utilizzato per effettuare le chiamate.
    private let apiService: APIService
    
    /// Insieme di cancellabili per gestire le sottoscrizioni Combine.
    private var cancellables = Set<AnyCancellable>()
    
    /// Callback per segnalare al coordinator di mostrare i dettagli di un Pokémon.
    var onShowPokemonDetails: ((PokemonListItem) -> Void)?
    
    // MARK: - Inizializzazione
    
    /// Inizializza il ViewModel.
    ///
    /// - Parameter apiService: Il servizio API da utilizzare (default: APIService()).
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        fetchPokemonList()
    }
    
    // MARK: - Metodi Pubblici
    
    /// Effettua il fetch della lista dei Pokémon.
    ///
    /// Se la variabile d'ambiente "SIMULATE_ERROR" è impostata a "1", simula un errore impostando l'alertInfo.
    /// Altrimenti, utilizza l'endpoint predefinito o quello fornito come parametro per effettuare il fetch.
    ///
    /// - Parameter url: URL opzionale da cui effettuare il fetch; se nil, viene usato l'endpoint di base.
    func fetchPokemonList(url: String? = nil) {
        // Verifica se la variabile d'ambiente per simulare un errore è attiva.
        if ProcessInfo.processInfo.environment["SIMULATE_ERROR"] == "1" {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
                   formattedLogMessage(endpoint: url, message: "Simulating error due to environment variable"))
            self.alertInfo = AlertInfo(id: .alert)
            return
        }
        
        // Determina l'endpoint da utilizzare per il fetch.
        let endpoint = url ?? Endpoints.baseURL.absoluteString
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(endpoint: endpoint, message: "Fetching pokemon list."))
        
        guard let requestURL = URL(string: endpoint) else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error,
                   formattedLogMessage(endpoint: endpoint, message: "Invalid URL."))
            return
        }
        
        // Effettua il fetch della lista dei Pokémon tramite Combine.
        apiService.fetchPokemonList(from: requestURL)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error,
                           formattedLogMessage(endpoint: endpoint, message: "Error fetching pokemon list: \(error)"))
                    self?.alertInfo = AlertInfo(id: .alert)
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                if let results = response.results {
                    self.pokemonList.append(contentsOf: results)
                }
                self.nextURL = response.next
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
                       formattedLogMessage(endpoint: endpoint, message: "Successfully fetched pokemon list."))
            })
            .store(in: &cancellables)
    }
    
    /// Carica la pagina successiva della lista dei Pokémon.
    ///
    /// Verifica che l'URL della pagina successiva sia disponibile e, in tal caso, chiama `fetchPokemonList(url:)` per effettuare il fetch.
    func loadNextPage() {
        guard let nextURL = self.nextURL, !nextURL.isEmpty else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
                   formattedLogMessage(message: "No next URL available to load next page."))
            return
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(endpoint: nextURL, message: "Loading next page."))
        fetchPokemonList(url: nextURL)
    }
    
    /// Innesca la visualizzazione dei dettagli per un determinato Pokémon.
    ///
    /// Questo metodo invoca il callback assegnato a `onShowPokemonDetails` per notificare al coordinator che deve mostrare i dettagli del Pokémon.
    ///
    /// - Parameter pokemon: Il Pokémon per cui mostrare i dettagli.
    func showPokemonDetails(pokemon: PokemonListItem) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(endpoint: pokemon.name, message: "Showing details"))
        onShowPokemonDetails?(pokemon)
    }
}
