//
//  Logger.swift
//  PokeDex
//
//  Created by vscocca on 14/03/25.
//

import os.log
import Foundation

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.vittorioscocca.pokedex.PokeDex"
    static let appLogger = OSLog(subsystem: subsystem, category: "app")
}


func formattedLogMessage(endpoint: String? = nil,
                         message: String,
                         function: String = #function,
                         file: String = #file) -> String {
    let isoTimestamp = ISO8601DateFormatter().string(from: Date())
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    let classInstance = fileName.replacingOccurrences(of: ".swift", with: "")
    let method = function
    let pid = ProcessInfo.processInfo.processIdentifier
    let ip = "N/A"
    let correlationId = "N/A"
    let reqId = "N/A"
    
    if let endpoint = endpoint, !endpoint.isEmpty {
        return "[\(isoTimestamp)]-[\(classInstance)]-[\(method)]-[\(endpoint)]-[\(pid)]-[\(ip)]-[\(correlationId)]-[\(reqId)]: \(message)"
    } else {
        return "[\(isoTimestamp)]-[\(classInstance)]-[\(method)]-[\(pid)]-[\(ip)]-[\(correlationId)]-[\(reqId)]: \(message)"
    }
}
