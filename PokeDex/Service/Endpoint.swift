//
//  Endpoint.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import Foundation
import os.log

/// Enum che definisce i tipi di contenuto accettabili per le richieste HTTP.
public enum ContentType: String {
    /// JSON: application/json.
    case json = "application/json"
    /// XML: application/xml.
    case xml = "application/xml"
    /// URL-encoded: application/x-www-form-urlencoded.
    case urlencoded = "application/x-www-form-urlencoded"
}

/// Restituisce `true` se il codice di stato HTTP è compreso tra 200 e 299.
///
/// - Parameter code: Il codice di stato HTTP.
/// - Returns: `true` se il codice è nel range 200..<300, altrimenti `false`.
public func expected200to300(_ code: Int) -> Bool {
    return (200..<300).contains(code)
}

/// Errore utilizzato quando la risposta è assente.
struct NoDataError: Error { }

/// Struttura generica che rappresenta un endpoint API.
/// Permette di configurare una richiesta HTTP completa, inclusi query parameters, headers e la funzione di parsing.
///
/// Il tipo generico `A` rappresenta il tipo di dato atteso in risposta.
public struct Endpoint<A> {
    
    /// Enum che definisce i metodi HTTP supportati.
    public enum Method: String {
        /// Metodo GET.
        case get     = "GET"
        /// Metodo POST.
        case post    = "POST"
        /// Metodo PUT.
        case put     = "PUT"
        /// Metodo PATCH.
        case patch   = "PATCH"
        /// Metodo DELETE.
        case delete  = "DELETE"
    }
    
    /// La richiesta HTTP configurata per l'endpoint.
    public var request: URLRequest
    /// Closure utilizzata per decodificare la risposta in un oggetto del tipo `A`.
    var parse: (Data?, URLResponse?) -> Result<A, Error>
    /// Closure per verificare se il codice di stato della risposta è accettabile.
    var expectedStatusCode: (Int) -> Bool
    
    // MARK: Inizializzatore Principale
    
    /// Inizializza un endpoint configurando la richiesta HTTP.
    ///
    /// - Parameters:
    ///   - method: Il metodo HTTP da utilizzare.
    ///   - url: L'URL base dell'endpoint.
    ///   - accept: (Opzionale) Il tipo di contenuto da accettare nella risposta.
    ///   - contentType: (Opzionale) Il tipo di contenuto della richiesta.
    ///   - body: (Opzionale) Il corpo della richiesta in formato `Data`.
    ///   - headers: Un dizionario di header HTTP da aggiungere alla richiesta.
    ///   - expectedStatusCode: Closure che verifica se il codice di stato della risposta è accettabile (default: expected200to300).
    ///   - timeOutInterval: Il timeout della richiesta in secondi (default: 60).
    ///   - query: Un dizionario di query parameters da aggiungere all'URL.
    ///   - parse: Closure che converte la risposta (Data e URLResponse) in un `Result<A, Error>`.
    public init(_ method: Method,
                url: URL,
                accept: ContentType? = nil,
                contentType: ContentType? = nil,
                body: Data? = nil,
                headers: [String: String] = [:],
                expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
                timeOutInterval: TimeInterval = 60,
                query: [String: String] = [:],
                parse: @escaping (Data?, URLResponse?) -> Result<A, Error>) {
        
        // Costruisce l'URL includendo i query parameters se presenti.
        let finalURL: URL = {
            guard !query.isEmpty,
                  var comps = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return url
            }
            comps.queryItems = (comps.queryItems ?? []) + query.map { URLQueryItem(name: $0.key, value: $0.value) }
            return comps.url ?? url
        }()
        
        // Crea la URLRequest.
        var req = URLRequest(url: finalURL, timeoutInterval: timeOutInterval)
        req.httpMethod = method.rawValue
        req.httpBody = body
        if let acc = accept { req.setValue(acc.rawValue, forHTTPHeaderField: "Accept") }
        if let cnt = contentType { req.setValue(cnt.rawValue, forHTTPHeaderField: "Content-Type") }
        headers.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        os_log("Endpoint URL: %{PUBLIC}@", finalURL.absoluteString)
        
        self.request = req
        self.expectedStatusCode = expectedStatusCode
        self.parse = parse
    }
    
    // MARK: Inizializzatore Alternativo
    
    /// Inizializzatore alternativo che utilizza una `URLRequest` già configurata.
    ///
    /// - Parameters:
    ///   - request: La `URLRequest` preconfigurata.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso (default: expected200to300).
    ///   - parse: Closure per decodificare la risposta.
    public init(request: URLRequest,
                expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
                parse: @escaping (Data?, URLResponse?) -> Result<A, Error>) {
        self.request = request
        self.expectedStatusCode = expectedStatusCode
        self.parse = parse
        os_log("Initialized Endpoint from existing URLRequest")
    }
}

// MARK: - Convenience per Endpoint JSON

extension Endpoint where A: Decodable {
    
    /// Inizializzatore di convenienza per endpoint che decodificano una risposta JSON (senza corpo della richiesta).
    ///
    /// - Parameters:
    ///   - method: Il metodo HTTP da utilizzare.
    ///   - url: L'URL dell'endpoint.
    ///   - accept: Il tipo di contenuto accettato (default: `.json`).
    ///   - headers: Header aggiuntivi da includere nella richiesta.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso (default: expected200to300).
    ///   - timeOutInterval: Il timeout per la richiesta in secondi (default: 60).
    ///   - query: Query parameters da aggiungere all'URL.
    ///   - decoder: Un'istanza di `JSONDecoder` per decodificare la risposta.
    public init(
        json method: Method,
        url: URL,
        accept: ContentType = .json,
        headers: [String: String] = [:],
        expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
        timeOutInterval: TimeInterval = 60,
        query: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.init(method,
                  url: url,
                  accept: accept,
                  body: nil,
                  headers: headers,
                  expectedStatusCode: expectedStatusCode,
                  timeOutInterval: timeOutInterval,
                  query: query) { data, _ in
            os_log("Decoding JSON response for URL: %{PUBLIC}@", url.absoluteString)
            return Result {
                guard let data = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: data)
            }
        }
        os_log("Initialized JSON Endpoint for URL: %{PUBLIC}@", url.absoluteString)
    }
    
    /// Inizializzatore di convenienza per endpoint che decodificano una risposta JSON e inviano un corpo codificabile.
    ///
    /// - Parameters:
    ///   - method: Il metodo HTTP da utilizzare.
    ///   - url: L'URL dell'endpoint.
    ///   - accept: Il tipo di contenuto accettato (default: `.json`).
    ///   - body: Un oggetto conformante a `Encodable` da inviare come corpo della richiesta.
    ///   - headers: Header aggiuntivi da includere nella richiesta.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso (default: expected200to300).
    ///   - timeOutInterval: Il timeout per la richiesta in secondi (default: 60).
    ///   - query: Query parameters da aggiungere all'URL.
    ///   - decoder: Un'istanza di `JSONDecoder` per decodificare la risposta.
    ///   - encoder: Un'istanza di `JSONEncoder` per codificare il corpo della richiesta.
    public init<B: Encodable>(
        json method: Method,
        url: URL,
        accept: ContentType = .json,
        body: B? = nil,
        headers: [String: String] = [:],
        expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
        timeOutInterval: TimeInterval = 60,
        query: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        let encodedBody = body.map { try! encoder.encode($0) }
        self.init(method,
                  url: url,
                  accept: accept,
                  contentType: .json,
                  body: encodedBody,
                  headers: headers,
                  expectedStatusCode: expectedStatusCode,
                  timeOutInterval: timeOutInterval,
                  query: query) { data, _ in
            os_log("Decoding JSON response for URL: %{PUBLIC}@", url.absoluteString)
            return Result {
                guard let data = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: data)
            }
        }
        os_log("Initialized JSON Endpoint (with body) for URL: %{PUBLIC}@", url.absoluteString)
    }
    
    /// Inizializzatore di convenienza che costruisce l'Endpoint a partire da una stringa di path.
    ///
    /// - Parameters:
    ///   - path: La stringa che rappresenta l'URL (o parte di esso).
    ///   - method: Il metodo HTTP da utilizzare (default: `.get`).
    ///   - query: Query parameters da aggiungere all'URL.
    ///   - headers: Header da includere nella richiesta.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso (default: expected200to300).
    ///   - timeOutInterval: Il timeout della richiesta in secondi (default: 60).
    ///   - decoder: Un'istanza di `JSONDecoder` per decodificare la risposta.
    public init(path: String,
                method: Method = .get,
                query: [String: String] = [:],
                headers: [String: String] = [:],
                expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
                timeOutInterval: TimeInterval = 60,
                decoder: JSONDecoder = JSONDecoder()) {
        let url = URL(string: path)!
        os_log("Initializing Endpoint from path: %{PUBLIC}@", url.absoluteString)
        self.init(method,
                  url: url,
                  accept: .json,
                  headers: headers,
                  expectedStatusCode: expectedStatusCode,
                  timeOutInterval: timeOutInterval,
                  query: query) { data, _ in
            os_log("Decoding JSON response from path initializer for URL: %{PUBLIC}@", url.absoluteString)
            return Result {
                guard let data = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: data)
            }
        }
    }
}
