//
//  PokemonListScreenViewModel.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//
import Foundation
import Combine
import os.log

typealias PokemonListScreenViewModelType = StateStoreViewModel<PokemonListScreenViewState, PokemonListScreenViewAction>

@MainActor
protocol PokemonListScreenViewModelProtocol {
    var actions: AnyPublisher<PokemonListScreenViewModelAction, Never> { get }
    var context: PokemonListScreenViewModelType.Context { get }
}

class PokemonListScreenViewModel: PokemonListScreenViewModelType,
                                  PokemonListScreenViewModelProtocol {
    private var actionsSubject: PassthroughSubject<PokemonListScreenViewModelAction, Never> = .init()
    private let apiService: APIService
    var actions: AnyPublisher<PokemonListScreenViewModelAction, Never> {
        self.actionsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - INIT
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        let bindings = PokemonListScreennViewStateBindings(count: nil,
                                                           pokemonList: [],
                                                           next: nil,
                                                           previous: nil)
        
        super.init(initialViewState: PokemonListScreenViewState(bindings: bindings))
        
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized. Starting to fetch pokemon list."))
        fetchPokemonList()
    }
    
    override func process(viewAction: PokemonListScreenViewAction) {
        switch viewAction {
        case .showPokemonDetails(let pokemon):
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Processing action: showPokemonDetails for pokemon: \(pokemon.name)"))
            self.actionsSubject.send(.didShowPokemonDetails(pokemon: pokemon))
        case .loadNextPage:
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Processing action: loadNextPage"))
            loadNextPage()
        }
    }
    
    // MARK: - Private
    private func fetchPokemonList(url: String? = nil) {
        Task {
            let endpoint = url ?? Endpoints.baseURL.absoluteString
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpoint, message: "Fetching pokemon list."))
            
            guard let url = URL(string: endpoint) else {
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: endpoint, message: "Invalid URL."))
                return
            }
            
            switch await self.apiService.fetchPokemonListAsync(from: url) {
            case .success(let response):
                guard let results = response.results else {
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: endpoint, message: "Response succeeded but 'results' is nil."))
                    self.handleError(.requestFailed)
                    return
                }
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpoint, message: "Successfully fetched pokemon list. Count: \(String(describing: response.count)), next: \(String(describing: response.next)), previous: \(String(describing: response.previous))."))
                
                self.state.bindings.pokemonList.append(contentsOf: results)
                self.state.bindings.count = response.count
                self.state.bindings.next = response.next
                self.state.bindings.previous = response.previous
            case .failure(let error):
                os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(endpoint: endpoint, message: "Error fetching pokemon list: \(error)"))
                self.handleError(error)
            }
        }
    }
    
    func loadNextPage() {
        if let nextURL = self.state.bindings.next {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: nextURL, message: "Loading next page."))
            fetchPokemonList(url: nextURL)
        } else {
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "No next URL available to load next page."))
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
