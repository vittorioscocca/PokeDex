//
//  Endpoints.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation

// swiftlint:disable force_unwrapping
enum Endpoints {
    static let scheme = "https://"
    static let domain = "pokeapi.co"
    static let apiPath = "/api"
    static let serverVersion = "/v2"
    static let appPath = "/pokemon"
    static let pokemonDitto = "/ditto"
    
    static var baseURL: URL {
        return URL(string: scheme + domain + apiPath + serverVersion + appPath)!
    }
    
    static func pokemonListResponse() -> Endpoint<PokemonListResponse> {
        print(baseURL.appendingPathComponent(pokemonDitto).absoluteString)
        return Endpoint(path: baseURL.absoluteString)
    }
    
    static func pokemonDetail(for pokemonDetailUrl: String) -> Endpoint<PokemonDetailResponse> {
        return Endpoint(path: pokemonDetailUrl)
    }
}
