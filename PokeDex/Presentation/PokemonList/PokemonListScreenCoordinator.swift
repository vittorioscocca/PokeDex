//
//  PokemonListScreenCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Combine
import SwiftUI
import os.log

/// coordinator per la schermata della lista dei Pokémon.
///
/// Il `PokemonListScreenCoordinator` implementa il protocollo `CoordinatorProtocol` e gestisce:
/// - La sottoscrizione alle azioni provenienti dal ViewModel della schermata dei Pokémon.
/// - La presentazione della schermata della lista tramite il `NavigationStackCoordinator`.
/// - La navigazione verso la schermata dei dettagli quando viene selezionato un Pokémon.
@MainActor
class PokemonListScreenCoordinator: CoordinatorProtocol {
    
    // MARK: - Proprietà Private
    
    /// coordinator dello stack di navigazione utilizzato per presentare le schermate.
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    /// Soggetto Combine per trasmettere azioni specifiche del coordinator.
    private let actionsSubject: PassthroughSubject<PokemonListScreenCoordinatorAction, Never> = .init()
    
    /// Publisher che espone le azioni del coordinator in modalità read-only.
    var actions: AnyPublisher<PokemonListScreenCoordinatorAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    /// Insieme per conservare le sottoscrizioni Combine.
    private var cancellables = Set<AnyCancellable>()
    
    /// ViewModel per la schermata della lista dei Pokémon, conforme a `PokemonListScreenViewModelProtocol`.
    private var viewModel: PokemonListScreenViewModelProtocol
    
    // MARK: - Inizializzazione
    
    /// Inizializza il coordinator della schermata della lista dei Pokémon.
    ///
    /// - Parameter navigationStackCoordinator: Il coordinator dello stack di navigazione utilizzato per presentare le schermate.
    ///
    /// L'inizializzatore crea un'istanza del ViewModel per la lista dei Pokémon e registra un log di debug.
    init(navigationStackCoordinator: NavigationStackCoordinator) {
        self.navigationStackCoordinator = navigationStackCoordinator
        self.viewModel = PokemonListScreenViewModel()
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonListScreenCoordinator initialized"))
    }
    
    // MARK: - Metodi del CoordinatorProtocol
    
    /// Avvia il coordinator della schermata della lista dei Pokémon.
    ///
    /// Il metodo sottoscrive il publisher delle azioni del ViewModel e gestisce l'azione di navigazione
    /// verso la schermata dei dettagli quando viene ricevuta l'azione `.didShowPokemonDetails`.
    func start() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonListScreenCoordinator started"))
        self.viewModel.actions.sink { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .didShowPokemonDetails(let pokemon):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Received action: didShowPokemonDetails for pokemon: \(pokemon.name)"))
                self.showPokemonDetails(pokemon: pokemon)
            }
        }.store(in: &self.cancellables)
    }
    
    /// Ferma il coordinator.
    ///
    /// In questo esempio, il metodo si limita a registrare un log di debug per indicare l'arresto del coordinator.
    func stop() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonListScreenCoordinator stopped"))
    }
    
    /// Restituisce una vista presentabile per la schermata della lista dei Pokémon.
    ///
    /// Il metodo invoca il metodo `toPresentable()` del ViewModel, che restituisce una `AnyView`
    /// contenente la schermata della lista, pronta per essere integrata nella gerarchia delle view.
    ///
    /// - Returns: Una `AnyView` contenente la schermata della lista dei Pokémon.
    func toPresentable() -> AnyView {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Presenting PokemonListScreen"))
        return AnyView(PokemonListScreen(context: self.viewModel.context))
    }
    
    // MARK: - Navigazione
    
    /// Gestisce la navigazione verso la schermata dei dettagli del Pokémon.
    ///
    /// - Parameter pokemon: L'oggetto `PokemonListItem` del Pokémon selezionato.
    ///
    /// Il metodo crea un nuovo coordinator per la schermata dei dettagli del Pokémon e lo aggiunge allo stack di navigazione
    /// tramite il `NavigationStackCoordinator`.
    func showPokemonDetails(pokemon: PokemonListItem) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Navigating to PokemonDetailsScreen for \(pokemon.name)"))
        let coordinator = PokemonDetailsScreenCoordinator(navigationStackCoordinator: self.navigationStackCoordinator, pokemon: pokemon)
        self.navigationStackCoordinator.push(coordinator)
    }
}
