//
//  PokemonDetails.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Combine
import SwiftUI
import os.log

/// Coordinatore responsabile della gestione della schermata dei dettagli del Pokémon.
///
/// Il `PokemonDetailsScreenCoordinator` implementa il protocollo `CoordinatorProtocol` ed è responsabile di:
/// - Inizializzare il ViewModel associato alla schermata dei dettagli del Pokémon.
/// - Gestire le azioni specifiche del coordinatore tramite un publisher.
/// - Fornire una vista presentabile per visualizzare la schermata dei dettagli.
@MainActor
class PokemonDetailsScreenCoordinator: CoordinatorProtocol {
    
    // MARK: - Proprietà Private
    
    /// Coordinatore dello stack di navigazione che gestisce la presentazione della schermata.
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    /// Soggetto Combine per trasmettere azioni specifiche del coordinatore.
    private let actionsSubject: PassthroughSubject<PokemonDetailsScreenCoordinatorAction, Never> = .init()
    
    /// Insieme di cancellables per conservare le sottoscrizioni Combine.
    private var cancellables = Set<AnyCancellable>()
    
    /// Il ViewModel per la schermata dei dettagli del Pokémon.
    private var viewModel: PokemonDetailsScreenViewModel
    
    // MARK: - Publisher
    
    /// Publisher che espone le azioni del coordinatore come `PokemonDetailsScreenCoordinatorAction`.
    var actions: AnyPublisher<PokemonDetailsScreenCoordinatorAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Inizializzazione
    
    /// Inizializza il coordinatore per la schermata dei dettagli del Pokémon.
    ///
    /// - Parameters:
    ///   - navigationStackCoordinator: Il coordinatore dello stack di navigazione che gestisce la presentazione delle schermate.
    ///   - pokemon: Un oggetto `PokemonListItem` contenente i dati basilari del Pokémon da visualizzare.
    ///
    /// L'inizializzatore crea il ViewModel per i dettagli del Pokémon e registra un log di debug per confermare l'avvio.
    init(navigationStackCoordinator: NavigationStackCoordinator, pokemon: PokemonListItem) {
        self.navigationStackCoordinator = navigationStackCoordinator
        self.viewModel = PokemonDetailsScreenViewModel(pokemon: pokemon)
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized PokemonDetailsScreenCoordinator with pokemon: \(pokemon.name)"))
    }
    
    // MARK: - Metodi del CoordinatorProtocol
    
    /// Avvia il coordinatore per la schermata dei dettagli del Pokémon.
    ///
    /// Questo metodo viene chiamato per inizializzare eventuali processi o configurazioni necessarie
    /// prima che la schermata venga presentata. In questo caso, viene semplicemente loggato l'avvio.
    func start() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonDetailsScreenCoordinator started"))
    }
    
    /// Ferma il coordinatore.
    ///
    /// Questo metodo viene utilizzato per interrompere eventuali processi gestiti dal coordinatore.
    /// In questo esempio, il metodo si limita a loggare la dismissione.
    func stop() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonDetailsScreenCoordinator stopped"))
    }
    
    /// Restituisce una vista presentabile per la schermata dei dettagli del Pokémon.
    ///
    /// Il metodo invoca il metodo `toPresentable()` del coordinatore dello stack di navigazione e
    /// registra un log di debug per indicare che la schermata dei dettagli sta per essere presentata.
    ///
    /// - Returns: Una `AnyView` contenente la vista della schermata dei dettagli del Pokémon.
    func toPresentable() -> AnyView {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Presenting PokemonDetailsScreen"))
        return AnyView(PokemonDetailsScreen(context: self.viewModel.context))
    }
}
