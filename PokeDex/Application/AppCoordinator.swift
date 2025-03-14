//
//  AppCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import SwiftUI
import Combine

@MainActor
class AppCoordinator: CoordinatorProtocol, ObservableObject {
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    init() {
        self.navigationStackCoordinator = NavigationStackCoordinator()
        start()
    }
    
    func start() {
        let pokemonListCoordinator = PokemonListScreenCoordinator(navigationStackCoordinator: self.navigationStackCoordinator)
        self.navigationStackCoordinator.setRootCoordinator(pokemonListCoordinator)
    }
    
    func toPresentable() -> AnyView {
        self.navigationStackCoordinator.toPresentable()
    }
}
