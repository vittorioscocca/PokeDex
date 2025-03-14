//
//  PokemonListScreenCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Combine
import SwiftUI
import os.log

@MainActor
class PokemonListScreenCoordinator: CoordinatorProtocol {
    private let navigationStackCoordinator: NavigationStackCoordinator
    private let actionsSubject: PassthroughSubject<PokemonListScreenCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<PokemonListScreenCoordinatorAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: PokemonListScreenViewModelProtocol
    
    init(navigationStackCoordinator: NavigationStackCoordinator) {
        self.navigationStackCoordinator = navigationStackCoordinator
        self.viewModel = PokemonListScreenViewModel()
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonListScreenCoordinator initialized"))
    }
    
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
    
    func stop() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonListScreenCoordinator stopped"))
    }
    
    func toPresentable() -> AnyView {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Presenting PokemonListScreen"))
        return AnyView(PokemonListScreen(context: self.viewModel.context))
    }
    
    func showPokemonDetails(pokemon: PokemonListItem) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Navigating to PokemonDetailsScreen for \(pokemon.name)"))
        let coordinator = PokemonDetailsScreenCoordinator(navigationStackCoordinator: self.navigationStackCoordinator, pokemon: pokemon)
        self.navigationStackCoordinator.push(coordinator)
    }
}
