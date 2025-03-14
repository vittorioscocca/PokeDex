//
//  PokemonDetails.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Combine
import SwiftUI
import os.log

@MainActor
class PokemonDetailsScreenCoordinator: CoordinatorProtocol {
    private let navigationStackCoordinator: NavigationStackCoordinator
    private let actionsSubject: PassthroughSubject<PokemonDetailsScreenCoordinatorAction, Never> = .init()
    var actions: AnyPublisher<PokemonDetailsScreenCoordinatorAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: PokemonDetailsScreenViewModel
    
    init(navigationStackCoordinator: NavigationStackCoordinator, pokemon: PokemonListItem) {
        self.navigationStackCoordinator = navigationStackCoordinator
        self.viewModel = PokemonDetailsScreenViewModel(pokemon: pokemon)
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized PokemonDetailsScreenCoordinator with pokemon: \(pokemon.name)"))
    }
    
    func start() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonDetailsScreenCoordinator started"))
    }
    
    func stop() {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokemonDetailsScreenCoordinator stopped"))
    }
    
    func toPresentable() -> AnyView {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Presenting PokemonDetailsScreen"))
        return AnyView(PokemonDetailsScreen(context: self.viewModel.context))
    }
}
