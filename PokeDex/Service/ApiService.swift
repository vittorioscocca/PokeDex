//
//  ApiService.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation
import Combine
import os.log

// MARK: - APIService

class APIService: ApiServiceProtocol {
    private let networkLoader: HTTPClientProtocol!
    private var cancellables = Set<AnyCancellable>()
    
    init(networkLoader: HTTPClientProtocol = HTTPClient()) {
        self.networkLoader = networkLoader
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "APIService initialized"))
    }
    
    func fetchPokemonList(from url: URL? = nil) -> AnyPublisher<PokemonListResponse, APIError> {
        let requestURL: URL
        if let url = url {
            requestURL = url
        } else {
            let baseURL = Endpoints.baseURL
            requestURL = baseURL
        }
        
        let endpointString = requestURL.absoluteString
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpointString, message: "Starting fetchPokemonList"))
        
        let endpoint = Endpoint<PokemonListResponse>(path: endpointString)
        return self.networkLoader.sendRequest(for: endpoint, on: RunLoop.main)
    }
    
    func fetchPokemonListAsync(from url: URL? = nil) async -> Result<PokemonListResponse, APIError> {
        let requestURL: URL
        if let url = url {
            requestURL = url
        } else {
            requestURL = Endpoints.baseURL
        }
        let endpointString = requestURL.absoluteString
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpointString, message: "Starting async fetchPokemonList"))
        
        return await withCheckedContinuation { continuation in
            self.fetchPokemonList(from: requestURL)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        // Non è necessario loggare qui, in quanto il risultato viene gestito nel receiveValue
                        break
                    case .failure(let error):
                        let errorMsg = formattedLogMessage(endpoint: endpointString, message: "Async fetchPokemonList failed with error: \(error)")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        continuation.resume(returning: .failure(error))
                    }
                }, receiveValue: { response in
                    let successMsg = formattedLogMessage(endpoint: endpointString, message: "Async fetchPokemonList succeeded")
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, successMsg)
                    continuation.resume(returning: .success(response))
                })
                .store(in: &cancellables)
        }
    }
    
    func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError> {
        let endpointString = url.absoluteString
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpointString, message: "Starting fetchPokemonDetail"))
        return self.networkLoader.sendRequest(for: Endpoints.pokemonDetail(for: endpointString), on: RunLoop.main)
    }
    
    func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError> {
        let endpointString = url.absoluteString
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpointString, message: "Starting async fetchPokemonDetail"))
        
        return await withCheckedContinuation { continuation in
            self.fetchPokemonDetail(from: url)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        let errorMsg = formattedLogMessage(endpoint: endpointString, message: "Async fetchPokemonDetail failed with error: \(error)")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        continuation.resume(returning: .failure(error))
                    }
                }, receiveValue: { response in
                    let successMsg = formattedLogMessage(endpoint: endpointString, message: "Async fetchPokemonDetail succeeded")
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, successMsg)
                    continuation.resume(returning: .success(response))
                })
                .store(in: &cancellables)
        }
    }
}



