//
//  PokeDexTests.swift
//  PokeDexTests
//
//  Created by vscocca on 10/03/25.
//

import Testing
@testable import PokeDex
import Combine
import Foundation
import XCTest

// MARK: - Stub per simulare APIService

/// Stub per simulare le chiamate a `APIService` nei test della schermata della lista dei Pokémon.
/// Configurando il flag `shouldReturnError` e assegnando una risposta di test a `testResponse`,
/// questo stub permette di controllare il comportamento del fetch asincrono.
class APIServiceStub: APIService {
    /// Se impostato a true, le chiamate API restituiranno un errore.
    var shouldReturnError = false
    /// La risposta di test da restituire in caso di successo per il fetch della lista dei Pokémon.
    var testResponse: PokemonListResponse?
    
    /// Simula il fetch asincrono della lista dei Pokémon (versione async/await).
    override func fetchPokemonListAsync(from url: URL? = nil) async -> Result<PokemonListResponse, APIError> {
        if shouldReturnError {
            return .failure(.requestFailed)
        } else {
            if let response = testResponse {
                return .success(response)
            } else {
                return .success(PokemonListResponse(count: 1, next: nil, previous: nil, results: []))
            }
        }
    }
    
    /// Implementa il fetch della lista dei Pokémon utilizzando Combine.
    override func fetchPokemonList(from url: URL? = nil) -> AnyPublisher<PokemonListResponse, APIError> {
        if shouldReturnError {
            return Fail(error: APIError.requestFailed)
                .eraseToAnyPublisher()
        } else {
            let response: PokemonListResponse = testResponse ?? PokemonListResponse(count: 1, next: nil, previous: nil, results: [])
            return Just(response)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
    }
    
    /// Metodo non utilizzato in questi test.
    override func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questi test")
    }
    
    /// Metodo non utilizzato in questi test.
    override func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questi test")
    }
}

// MARK: - Test per PokemonListScreenViewModel

/// Test suite per verificare il comportamento del ViewModel della lista dei Pokémon.
struct PokeDexTests {
    
    /// Verifica che, in caso di risposta positiva, le proprietà del ViewModel vengano aggiornate correttamente.
    ///
    /// Il test configura lo stub per restituire una risposta positiva contenente un `PokemonListItem` e controlla che:
    /// - La lista dei Pokémon (`pokemonList`) contenga il `PokemonListItem` di test.
    /// - Non venga impostato alcun alert.
    @Test func testPokemonListScreenViewModelSuccess() async throws {
        let stub = APIServiceStub()
        let testItem = PokemonListItem(
                                       name: "pikachu",
                                       url: "https://pokeapi.co/api/v2/pokemon/25")
        let response = PokemonListResponse(count: 1,
                                           next: nil,
                                           previous: nil,
                                           results: [testItem])
        stub.testResponse = response
        stub.shouldReturnError = false
        
        let viewModel = PokemonListScreenViewModel(apiService: stub)
        
        // Attende per consentire il completamento dell'aggiornamento asincrono.
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(response.count == 1)
        #expect(viewModel.pokemonList == [testItem])
        #expect(response.next == nil)
        #expect(response.previous == nil)
        #expect(viewModel.alertInfo == nil)
    }
    
    /// Verifica che, in caso di errore durante il fetch, venga impostato un alert.
    ///
    /// Il test configura lo stub per restituire un errore e controlla che l'alert venga impostato.
    @Test func testPokemonListScreenViewModelFailure() async throws {
        let stub = APIServiceStub()
        stub.shouldReturnError = true
        
        let viewModel = PokemonListScreenViewModel(apiService: stub)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(viewModel.alertInfo != nil)
    }
}
