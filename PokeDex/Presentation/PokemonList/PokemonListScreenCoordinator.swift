//
//  PokemonListScreenCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI
import Combine
import os.log

/// Coordinator per la schermata della lista dei Pokémon.
///
/// Il coordinator si occupa di:
/// - Inizializzare il ViewModel della lista dei Pokémon.
/// - Gestire il callback per la navigazione alla schermata dei dettagli.
/// - Fornire la view presentabile tramite il metodo `toPresentable()`.
@MainActor
class PokemonListScreenCoordinator: CoordinatorProtocol {
    
    // MARK: - Proprietà Private
    
    /// Coordinator dello stack di navigazione utilizzato per la gestione delle transizioni.
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    ///Api service utilizzato per il fetch della lista dei Pokemon
    private let apiService: APIService
    
    /// ViewModel per la schermata della lista dei Pokémon.
    private var viewModel: PokemonListScreenViewModel
    
    /// Insieme di cancellabili per gestire le sottoscrizioni Combine.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inizializzazione
    
    /// Inizializza il coordinator per la schermata della lista dei Pokémon.
    ///
    /// - Parameter navigationStackCoordinator: Il coordinator dello stack di navigazione da utilizzare.
    init(navigationStackCoordinator: NavigationStackCoordinator,
         apiService: APIService = APIService()) {
        self.navigationStackCoordinator = navigationStackCoordinator
        self.apiService = apiService
        self.viewModel = PokemonListScreenViewModel(apiService: apiService)
        
        // Assegna il callback per mostrare i dettagli del Pokémon.
        // Quando il ViewModel invoca onShowPokemonDetails, viene chiamato il metodo showPokemonDetails del coordinator.
        self.viewModel.onShowPokemonDetails = { [weak self] pokemon in
            self?.showPokemonDetails(pokemon: pokemon)
        }
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "PokemonListScreenCoordinator initialized"))
    }
    
    // MARK: - Metodi del CoordinatorProtocol
    
    /// Avvia il coordinator.
    ///
    /// Questo metodo può essere utilizzato per avviare eventuali processi o sottoscrizioni necessari.
    func start() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "PokemonListScreenCoordinator started"))
    }
    
    /// Ferma il coordinator.
    ///
    /// Utilizzato per eseguire operazioni di cleanup, se necessario.
    func stop() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "PokemonListScreenCoordinator stopped"))
    }
    
    /// Restituisce una view presentabile per la schermata della lista dei Pokémon.
    ///
    /// - Returns: Una AnyView contenente la view della lista dei Pokémon.
    func toPresentable() -> AnyView {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Presenting PokemonListScreen"))
        return AnyView(PokemonListScreen(viewModel: self.viewModel))
    }
    
    // MARK: - Navigazione
    
    /// Gestisce la navigazione verso la schermata dei dettagli del Pokémon.
    ///
    /// - Parameter pokemon: L'oggetto PokemonListItem per il quale mostrare i dettagli.
    func showPokemonDetails(pokemon: PokemonListItem) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Navigating to PokemonDetailsScreen for \(pokemon.name)"))
        let detailsCoordinator = PokemonDetailsScreenCoordinator(navigationStackCoordinator: self.navigationStackCoordinator, pokemon: pokemon)
        detailsCoordinator.start()
        self.navigationStackCoordinator.push(detailsCoordinator)
    }
}
