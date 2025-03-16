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

/// Un servizio per interagire con le API relative ai dati sui Pokémon.
/// Utilizza Combine per gestire i flussi asincroni e async/await.
/// Il servizio si appoggia a un client HTTP che rispetta il protocollo `HTTPClientProtocol`.
class APIService: ApiServiceProtocol {
    
    /// Il client HTTP per effettuare le richieste di rete.
    private let networkLoader: HTTPClientProtocol!
    
    /// Insieme di  Combine per conservare le sottoscrizioni e gestire la cancellazione.
    private var cancellables = Set<AnyCancellable>()
    
    /// Inizializza il servizio API.
    /// - Parameter networkLoader: Il client HTTP da utilizzare. Di default viene usata un'istanza di `HTTPClient`.
    init(networkLoader: HTTPClientProtocol = HTTPClient()) {
        self.networkLoader = networkLoader
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "APIService initialized"))
    }
    
    /// Recupera la lista dei Pokémon.
    ///
    /// Se viene passato un URL, il servizio lo utilizza; altrimenti imposta l’URL di default definito in `Endpoints.baseURL`.
    ///
    /// - Parameter url: URL opzionale per la richiesta.
    /// - Returns: Un publisher che emette una `PokemonListResponse` o un `APIError`.
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
        
        return self.networkLoader.sendRequest(for: Endpoint<PokemonListResponse>(path: endpointString), on: RunLoop.main)
    }
    
    /// Recupera la lista dei Pokémon in modo asincrono utilizzando async/await.
    ///
    /// Se viene passato un URL, il servizio lo utilizza; altrimenti imposta l’URL di default definito in `Endpoints.baseURL`.
    ///
    /// - Parameter url: URL opzionale per la richiesta.
    /// - Returns: Un `Result` contenente una `PokemonListResponse` in caso di successo o un `APIError` in caso di errore.
    func fetchPokemonListAsync(from url: URL? = nil) async -> Result<PokemonListResponse, APIError> {
        let requestURL: URL
        if let url = url {
            requestURL = url
        } else {
            requestURL = Endpoints.baseURL
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: requestURL.absoluteString, message: "Starting async fetchPokemonList"))
        
        return await withCheckedContinuation { continuation in
            self.fetchPokemonList(from: requestURL)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        // Non è necessario loggare qui, in quanto il risultato viene gestito in `receiveValue`.
                        break
                    case .failure(let error):
                        let errorMsg = formattedLogMessage(endpoint: requestURL.absoluteString, message: "Async fetchPokemonList failed with error: \(error)")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        continuation.resume(returning: .failure(error))
                    }
                }, receiveValue: { response in
                    let successMsg = formattedLogMessage(endpoint: requestURL.absoluteString, message: "Async fetchPokemonList succeeded")
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, successMsg)
                    continuation.resume(returning: .success(response))
                })
                .store(in: &cancellables)
        }
    }
    
    /// Recupera i dettagli di un Pokémon a partire da un URL.
    ///
    /// - Parameter url: L'URL specifico per i dettagli del Pokémon.
    /// - Returns: Un publisher che emette una `PokemonDetailResponse` o un `APIError`.
    func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError> {
        let endpointString = url.absoluteString
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: endpointString, message: "Starting fetchPokemonDetail"))
        return self.networkLoader.sendRequest(for: Endpoints.pokemonDetail(for: endpointString), on: RunLoop.main)
    }
    
    /// Recupera in modo asincrono i dettagli di un Pokémon a partire da un URL utilizzando async/await.
    ///
    /// - Parameter url: L'URL per i dettagli del Pokémon.
    /// - Returns: Un `Result` contenente una `PokemonDetailResponse` in caso di successo o un `APIError` in caso di errore.
    func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError> {
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Starting async fetchPokemonDetail"))
        
        return await withCheckedContinuation { continuation in
            self.fetchPokemonDetail(from: url)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        let errorMsg = formattedLogMessage(endpoint: url.absoluteString, message: "Async fetchPokemonDetail failed with error: \(error)")
                        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, errorMsg)
                        continuation.resume(returning: .failure(error))
                    }
                }, receiveValue: { response in
                    let successMsg = formattedLogMessage(endpoint: url.absoluteString, message: "Async fetchPokemonDetail succeeded")
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, successMsg)
                    continuation.resume(returning: .success(response))
                })
                .store(in: &cancellables)
        }
    }
}



