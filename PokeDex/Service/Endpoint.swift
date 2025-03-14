//
//  Endpoint.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//
import Foundation
import Combine
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import os.log

// MARK: - Content Type e Utilità

/// Definisce i tipi di contenuto accettabili per le richieste HTTP.
public enum ContentType: String {
    /// JSON: application/json.
    case json = "application/json"
    /// XML: application/xml.
    case xml = "application/xml"
    /// URL-encoded: application/x-www-form-urlencoded.
    case urlencoded = "application/x-www-form-urlencoded"
}

/// Restituisce `true` se il codice di stato HTTP è compreso tra 200 e 299.
/// - Parameter code: Il codice di stato HTTP.
/// - Returns: `true` se il codice è nel range 200..<300, altrimenti `false`.
public func expected200to300(_ code: Int) -> Bool {
    return (200..<300).contains(code)
}

/// Errore utilizzato quando la risposta è assente.
struct NoDataError: Error { }

// MARK: - Struct Endpoint

/// Struttura generica che rappresenta un endpoint API.
/// Permette di configurare una richiesta HTTP completa, inclusi query parameters, headers e la funzione di parsing.
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
    var expectedStatusCode: (Int) -> Bool = expected200to300
    
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
    ///   - expectedStatusCode: Una closure che verifica se il codice di stato della risposta è accettabile.
    ///   - timeOutInterval: Il timeout della richiesta in secondi (default: 60).
    ///   - query: Un dizionario di query parameters da aggiungere all'URL.
    ///   - parse: La closure che converte la risposta (Data e URLResponse) in un `Result<A, Error>`.
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
        
        // Costruzione dell'URL con eventuali query parameters
        let requestUrl: URL
        if query.isEmpty {
            requestUrl = url
        } else {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            comps.queryItems = comps.queryItems ?? []
            comps.queryItems?.append(contentsOf: query.map { URLQueryItem(name: $0.key, value: $0.value) })
            requestUrl = comps.url!
        }
        
        // Log: URL costruito
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: requestUrl.absoluteString, message: "Constructed URL for Endpoint"))
        
        // Creazione del URLRequest
        request = URLRequest(url: requestUrl)
        if let acc = accept {
            request.setValue(acc.rawValue, forHTTPHeaderField: "Accept")
        }
        if let cnt = contentType {
            request.setValue(cnt.rawValue, forHTTPHeaderField: "Content-Type")
        }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = timeOutInterval
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Log: URLRequest creato
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: requestUrl.absoluteString, message: "Created URLRequest with method: \(method.rawValue)"))
        
        self.expectedStatusCode = expectedStatusCode
        self.parse = parse
    }
    
    // MARK: Inizializzatore Alternativo
    
    /// Inizializzatore alternativo che utilizza una URLRequest già configurata.
    ///
    /// - Parameters:
    ///   - request: La URLRequest preconfigurata.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso (default: expected200to300).
    ///   - parse: La closure per decodificare la risposta.
    public init(request: URLRequest,
                expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
                parse: @escaping (Data?, URLResponse?) -> Result<A, Error>) {
        self.request = request
        self.expectedStatusCode = expectedStatusCode
        self.parse = parse
        // Log: Inizializzatore alternativo usato
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized Endpoint from existing URLRequest"))
    }
}

extension Endpoint: CustomStringConvertible {
    /// Una rappresentazione testuale dell'endpoint, utile per il debug.
    public var description: String {
        let data = request.httpBody ?? Data()
        return "\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "<no url>") \(String(data: data, encoding: .utf8) ?? "")"
    }
}

// MARK: - Convenience Initializers per JSON

extension Endpoint where A: Decodable {
    
    /// Inizializzatore di convenienza per endpoint che decodificano una risposta JSON.
    ///
    /// - Parameters:
    ///   - method: Il metodo HTTP da utilizzare.
    ///   - url: L'URL dell'endpoint.
    ///   - accept: Il tipo di contenuto accettato, di default `.json`.
    ///   - headers: Header aggiuntivi da includere nella richiesta.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso.
    ///   - timeOutInterval: Il timeout per la richiesta, in secondi (default: 60).
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
        self.init(
            method,
            url: url,
            accept: accept,
            body: nil,
            headers: headers,
            expectedStatusCode: expectedStatusCode,
            timeOutInterval: timeOutInterval,
            query: query
        ) { data, _ in
            // Log: Decodifica della risposta JSON
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Decoding JSON response"))
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: dat)
            }
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Initialized JSON Endpoint for url"))
    }
    
    /// Inizializzatore di convenienza per endpoint che decodificano una risposta JSON e inviano un corpo codificabile.
    ///
    /// - Parameters:
    ///   - method: Il metodo HTTP da utilizzare.
    ///   - url: L'URL dell'endpoint.
    ///   - accept: Il tipo di contenuto accettato, di default `.json`.
    ///   - body: Un oggetto conformante a `Encodable` da inviare come corpo della richiesta.
    ///   - headers: Header aggiuntivi da includere nella richiesta.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso.
    ///   - timeOutInterval: Il timeout per la richiesta, in secondi (default: 60).
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
        let encodedBody = body.map { try! encoder.encode($0) } // Force try per semplicità
        self.init(
            method,
            url: url,
            accept: accept,
            contentType: .json,
            body: encodedBody,
            headers: headers,
            expectedStatusCode: expectedStatusCode,
            timeOutInterval: timeOutInterval,
            query: query
        ) { data, _ in
            // Log: Decodifica della risposta JSON
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Decoding JSON response"))
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: dat)
            }
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Initialized JSON Endpoint (with body) for url"))
    }
}

public extension Endpoint where A: Decodable {
    /// Inizializzatore di convenienza che costruisce l'Endpoint a partire da una stringa di path.
    ///
    /// - Parameters:
    ///   - path: La stringa che rappresenta l'URL (o parte di esso).
    ///   - method: Il metodo HTTP da utilizzare. Di default è `.get`.
    ///   - query: Un dizionario di query parameters da aggiungere all'URL.
    ///   - headers: Un dizionario di header da includere nella richiesta.
    ///   - expectedStatusCode: Closure per verificare il codice di stato atteso.
    ///   - timeOutInterval: Il timeout della richiesta in secondi (default: 60).
    ///   - decoder: Un'istanza di `JSONDecoder` per decodificare la risposta JSON.
    init(path: String,
         method: Method = .get,
         query: [String: String] = [:],
         headers: [String: String] = [:],
         expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
         timeOutInterval: TimeInterval = 60,
         decoder: JSONDecoder = JSONDecoder()) {
        
        let url = URL(string: path)!
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Initializing Endpoint from path"))
        
        self.init(method,
                  url: url,
                  accept: .json,
                  headers: headers,
                  expectedStatusCode: expectedStatusCode,
                  timeOutInterval: timeOutInterval,
                  query: query) { data, _ in
            // Log: Decodifica per convenienza dall'inizializzatore con path
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Decoding JSON response from path initializer"))
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: dat)
            }
        }
    }
}

