//
//  AppCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//

import SwiftUI
import Combine

/// Il coordinatore principale dell'applicazione che gestisce la navigazione e l'avvio delle schermate iniziali.
///
/// `AppCoordinator` implementa il protocollo `CoordinatorProtocol` ed è un oggetto osservabile (`ObservableObject`),
/// il che consente di notificare le view SwiftUI di eventuali cambiamenti nello stato di navigazione.
/// La classe è contrassegnata con `@MainActor` per garantire che tutte le operazioni siano eseguite sul thread principale,
/// in quanto interagisce con la UI.
@MainActor
class AppCoordinator: CoordinatorProtocol, ObservableObject {
    
    /// Il coordinator che gestisce lo stack di navigazione dell'app.
    ///
    /// Viene utilizzato per impostare e gestire i vari moduli di navigazione, inclusa la schermata principale e le eventuali presentazioni di sheet o fullscreen cover.
    private let navigationStackCoordinator: NavigationStackCoordinator
    
    private let apiService: APIService
    
    /// Inizializza il coordinator principale.
    ///
    /// All'istanziazione, viene creato un `NavigationStackCoordinator` e viene avviato il processo di navigazione chiamando il metodo `start()`.
    init() {
        self.navigationStackCoordinator = NavigationStackCoordinator()
        self.apiService = APIService()
        start()
    }
    
    /// Avvia il coordinator principale configurando la schermata iniziale dell'app.
    ///
    /// In questo caso, viene creato un coordinator per la schermata della lista dei Pokémon (`PokemonListScreenCoordinator`)
    /// e viene impostato come coordinator radice dello stack di navigazione. Questo metodo definisce il flusso iniziale dell'app.
    func start() {
        let pokemonListCoordinator = PokemonListScreenCoordinator(navigationStackCoordinator: self.navigationStackCoordinator,
                                                                  apiService: self.apiService)
        self.navigationStackCoordinator.setRootCoordinator(pokemonListCoordinator)
    }
    
    /// Restituisce una vista presentabile che incapsula l'intera gerarchia di navigazione gestita dal coordinator.
    ///
    /// Questo metodo permette di integrare la navigazione nella gerarchia delle view SwiftUI, fornendo un `AnyView`
    /// ottenuto dal `NavigationStackCoordinator`.
    ///
    /// - Returns: Una `AnyView` contenente la gerarchia di navigazione attualmente configurata.
    func toPresentable() -> AnyView {
        self.navigationStackCoordinator.toPresentable()
    }
}
