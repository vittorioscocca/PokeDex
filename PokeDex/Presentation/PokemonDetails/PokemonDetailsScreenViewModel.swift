//
//  PokemonDetailsScreenViewModel.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import Foundation
import Combine
import os.log

typealias PokemonDetailsScreenViewModelType = StateStoreViewModel<PokemonDetailsScreenViewState, PokemonDetailsScreenViewAction>

@MainActor
protocol PokemonDetailsScreenViewModelProtocol {
    var actions: AnyPublisher<PokemonDetailsScreenViewModelAction, Never> { get }
    var context: PokemonDetailsScreenViewModelType.Context { get }
}

class PokemonDetailsScreenViewModel: PokemonDetailsScreenViewModelType,
                                     PokemonDetailsScreenViewModelProtocol {
    private var actionsSubject: PassthroughSubject<PokemonDetailsScreenViewModelAction, Never> = .init()
    var actions: AnyPublisher<PokemonDetailsScreenViewModelAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    private var apiService: APIService
    
    init(pokemon: PokemonListItem, apiService: APIService = APIService()) {
        self.apiService = apiService
        
        let initialState = PokemonDetailsScreenViewState(
            bindings: PokemonDetailsScreenViewStateBindings(
                name: pokemon.name,
                imageURL: pokemon.imageURL,
                height: 0,
                weight: 0,
                abilities: [],
                moves: []
            )
        )
        
        super.init(initialViewState: initialState)
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized PokemonDetailsScreenViewModel for pokemon: \(pokemon.name)"))
        fetchPokemonDetails(for: pokemon.url)
    }
    
    private func fetchPokemonDetails(for url: String) {
        guard let detailURL = URL(string: url) else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Invalid URL: \(url)"))
            return
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: detailURL.absoluteString, message: "Fetching pokemon details."))
        Task {
            switch await self.apiService.fetchPokemonDetailAsync(from: detailURL) {
            case .success(let response):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: detailURL.absoluteString, message: "Successfully fetched details. Height: \(response.height), Weight: \(response.weight)"))
                self.state.bindings.height = response.height
                self.state.bindings.weight = response.weight
                self.state.bindings.abilities = response.abilities.map { $0.ability.name }
                self.state.bindings.moves = response.moves.map { $0.move.name }
            case .failure(let error):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: detailURL.absoluteString, message: "Error fetching details: \(error)"))
                self.handleError(error)
            }
        }
    }
    
    override func process(viewAction: PokemonDetailsScreenViewAction) {
        switch viewAction {
        case .toggleAbilities:
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Toggling abilities display."))
            self.state.bindings.showAbilities.toggle()
        case .toggleMoves:
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Toggling moves display."))
            self.state.bindings.showMoves.toggle()
        }
    }
    
    /// Processes an error to either update the flow or display it to the user.
    private func handleError(_ errorCode: APIError) {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Handling error: \(errorCode)"))
        switch errorCode {
        default:
            self.state.bindings.alertInfo = AlertInfo(id: .alert)
        }
    }
}
