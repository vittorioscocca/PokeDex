//
//  PokeDexApp.swift
//  PokeDex
//
//  Created by vscocca on 10/03/25.
//

import SwiftUI
import os.log

@main
struct PokeDexApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    init() {
        // Log di debug al lancio dell'app, formattato automaticamente.
        os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "PokeDexApp launched"))
    }
    
    var body: some Scene {
        WindowGroup {
            appCoordinator.toPresentable()
                .onAppear {
                    // Log di debug quando la view principale appare.
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .debug, formattedLogMessage(message: "AppCoordinator view appeared"))
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // Log di errore in caso di ricezione di un avviso di memoria.
                    os_log("%{PUBLIC}@", log: OSLog.appLogger, type: .error, formattedLogMessage(message: "Memory warning received"))
                }
        }
    }
}

