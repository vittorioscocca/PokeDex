//
//  PokemonDetails.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI
import Combine
import os.log

/// Coordinator per la schermata dei dettagli del Pokémon.
///
/// Questo coordinator si occupa di inizializzare il ViewModel della schermata dei dettagli e di
/// fornire la view presentabile tramite il metodo `toPresentable()`.
@MainActor
class PokemonDetailsScreenCoordinator: CoordinatorProtocol {
    
    // MARK: - Proprietà Private
    
    /// Coordinator dello stack di navigazione, utilizzato per gestire la navigazione tra le schermate.
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    /// ViewModel per la schermata dei dettagli, che fornisce i dati e le logiche per la view.
    private var viewModel: PokemonDetailsScreenViewModel
    
    /// Insieme di cancellabili per gestire le sottoscrizioni Combine.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inizializzazione
    
    /// Inizializza il coordinator per la schermata dei dettagli.
    ///
    /// - Parameters:
    ///   - navigationStackCoordinator: Il coordinator dello stack di navigazione a cui è associato.
    ///   - pokemon: Il Pokémon selezionato, usato per inizializzare il ViewModel.
    init(navigationStackCoordinator: NavigationStackCoordinator, pokemon: PokemonListItem) {
        self.navigationStackCoordinator = navigationStackCoordinator
        // Inizializza il ViewModel semplificato per la schermata dei dettagli, passando il Pokémon selezionato.
        self.viewModel = PokemonDetailsScreenViewModel(pokemon: pokemon)
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Initialized PokemonDetailsScreenCoordinator with pokemon: \(pokemon.name)"))
    }
    
    // MARK: - Metodi del CoordinatorProtocol
    
    /// Avvia il coordinator.
    ///
    /// Qui è possibile aggiungere eventuali sottoscrizioni al ViewModel o altre logiche di setup.
    func start() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "PokemonDetailsScreenCoordinator started"))
    }
    
    /// Ferma il coordinator.
    ///
    /// Esegue operazioni di cleanup, come la cancellazione delle sottoscrizioni o il rilascio di risorse.
    func stop() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "PokemonDetailsScreenCoordinator stopped"))
    }
    
    /// Restituisce una view presentabile che incapsula la schermata dei dettagli del Pokémon.
    ///
    /// - Returns: Una AnyView che contiene la PokemonDetailsScreen configurata con il relativo ViewModel.
    func toPresentable() -> AnyView {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug,
               formattedLogMessage(message: "Presenting PokemonDetailsScreen"))
        // Restituisce la view dei dettagli passando il ViewModel già inizializzato.
        return AnyView(PokemonDetailsScreen(viewModel: self.viewModel))
    }
}
