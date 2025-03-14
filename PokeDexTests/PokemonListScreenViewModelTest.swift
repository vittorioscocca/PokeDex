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

class APIServiceStub: APIService {
    var shouldReturnError = false
    var testResponse: PokemonListResponse?
    
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
    
    override func fetchPokemonList(from url: URL? = nil) -> AnyPublisher<PokemonListResponse, APIError> {
        fatalError("Non usato in questi test")
    }
    
    override func fetchPokemonDetailAsync(from url: URL) async -> Result<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questi test")
    }
    
    override func fetchPokemonDetail(from url: URL) -> AnyPublisher<PokemonDetailResponse, APIError> {
        fatalError("Non usato in questi test")
    }
}

// MARK: - Test per PokemonListScreenViewModel

struct PokeDexTests {
    
    // Test per verificare che, in caso di risposta positiva, lo state venga aggiornato correttamente
    @Test func testPokemonListScreenViewModelSuccess() async throws {
        let stub = APIServiceStub()
        let testItem = PokemonListItem(name: "pikachu",
                                       url: "https://pokeapi.co/api/v2/pokemon/25")
        let response = PokemonListResponse(count: 1,
                                           next: nil,
                                           previous: nil,
                                           results: [testItem])
        stub.testResponse = response
        stub.shouldReturnError = false
        
        let viewModel = await PokemonListScreenViewModel(apiService: stub)
        
        // Attende per consentire il completamento dell'aggiornamento asincrono
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await #expect(viewModel.state.bindings.count == 1)
        await  #expect(viewModel.state.bindings.pokemonList == [testItem])
        await #expect(viewModel.state.bindings.next == nil)
        await #expect(viewModel.state.bindings.previous == nil)
        await #expect(viewModel.state.bindings.alertInfo == nil)
    }
    
    // Test per verificare che, in caso di errore, venga impostato un alert nello state
    @Test func testPokemonListScreenViewModelFailure() async throws {
        let stub = APIServiceStub()
        stub.shouldReturnError = true
        
        let viewModel = await PokemonListScreenViewModel(apiService: stub)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await #expect(viewModel.state.bindings.alertInfo != nil)
    }
    
}
