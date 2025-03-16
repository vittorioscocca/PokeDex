//
//  Endpoints.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation

// swiftlint:disable force_unwrapping

/// Gestisce la configurazione degli endpoint per l'accesso alla PokeAPI.
enum Endpoints {
    
    // MARK: - Costanti URL
    
    /// Il prefisso dell'URL, che definisce il protocollo HTTPS.
    static let scheme = "https://"
    
    /// Il dominio della PokeAPI.
    static let domain = "pokeapi.co"
    
    /// Il percorso base per l'API.
    static let apiPath = "/api"
    
    /// La versione del server dell'API.
    static let serverVersion = "/v2"
    
    /// Il percorso dell'applicazione che gestisce le operazioni sui Pokémon.
    static let appPath = "/pokemon"
    
    /// Endpoint specifico per il Pokémon "ditto".
    static let pokemonDitto = "/ditto"
    
    // MARK: - Proprietà URL
    
    /// URL di base per l'accesso all'API dei Pokémon.
    ///
    /// Costruito concatenando lo schema, il dominio, il percorso API, la versione del server e il percorso dell'app.
    static var baseURL: URL {
        return URL(string: scheme + domain + apiPath + serverVersion + appPath)!
    }
    
    // MARK: - Endpoint Methods
    
    /// Crea un endpoint per recuperare la lista dei Pokémon.
    ///
    /// Questo metodo, restituisce un `Endpoint<PokemonListResponse>` configurato con l'URL di base.
    ///
    /// - Returns: Un endpoint configurato per ottenere una `PokemonListResponse` dalla PokeAPI.
    static func pokemonListResponse() -> Endpoint<PokemonListResponse> {
        return Endpoint(path: baseURL.absoluteString)
    }
    
    /// Crea un endpoint per recuperare i dettagli di un Pokémon.
    ///
    /// - Parameter pokemonDetailUrl: Una stringa contenente l'URL specifico per i dettagli del Pokémon.
    /// - Returns: Un endpoint configurato per ottenere una `PokemonDetailResponse` dalla PokeAPI.
    static func pokemonDetail(for pokemonDetailUrl: String) -> Endpoint<PokemonDetailResponse> {
        return Endpoint(path: pokemonDetailUrl)
    }
    
    // MARK: - Image URL
    
    /// Base URL per le immagini dei Pokémon.
    static let imageBaseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/"
 
    /// Restituisce l'URL per l'immagine dello sprite di un Pokémon in base al suo ID.
    static func imageURL(for id: String) -> URL? {
        return URL(string: imageBaseURL + "\(id).png")
    }
}
