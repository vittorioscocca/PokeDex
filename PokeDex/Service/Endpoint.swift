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

public enum ContentType: String {
    case json = "application/json"
    case xml = "application/xml"
    case urlencoded = "application/x-www-form-urlencoded"
}

/// Restituisce true se il codice è compreso tra 200 e 299.
public func expected200to300(_ code: Int) -> Bool {
    return (200..<300).contains(code)
}

/// Errore da utilizzare quando manca la response.
struct NoDataError: Error { }

// MARK: - Struct Endpoint

public struct Endpoint<A> {
    
    public enum Method: String {
        case get     = "GET"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
    }
    
    public var request: URLRequest
    var parse: (Data?, URLResponse?) -> Result<A, Error>
    var expectedStatusCode: (Int) -> Bool = expected200to300
    
    // Inizializzatore principale
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
    
    // Inizializzatore alternativo che parte da una URLRequest già formata
    public init(request: URLRequest, expectedStatusCode: @escaping (Int) -> Bool = expected200to300, parse: @escaping (Data?, URLResponse?) -> Result<A, Error>) {
        self.request = request
        self.expectedStatusCode = expectedStatusCode
        self.parse = parse
        // Log: Inizializzatore alternativo usato
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "Initialized Endpoint from existing URLRequest"))
    }
}

extension Endpoint: CustomStringConvertible {
    public var description: String {
        let data = request.httpBody ?? Data()
        return "\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "<no url>") \(String(data: data, encoding: .utf8) ?? "")"
    }
}

// Inizializzatori di convenienza per JSON
extension Endpoint where A: Decodable {
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
            method, url: url,
            accept: accept,
            body: nil,
            headers: headers,
            expectedStatusCode: expectedStatusCode,
            timeOutInterval: timeOutInterval,
            query: query
        ) { data, _ in
            // Log: Inizializzatore JSON
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Decoding JSON response"))
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: dat)
            }
        }
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Initialized JSON Endpoint for url"))
    }
    
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
    /// Inizializzatore di convenienza che costruisce l'URL a partire dal path.
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
            // Log: Decodifica per convenienza
            os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(endpoint: url.absoluteString, message: "Decoding JSON response from path initializer"))
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(A.self, from: dat)
            }
        }
    }
}

