//
//  CoordinatorProtocol.swift
//  PokeDex
//
//  Created by vscocca on 11/03/25.
//

import SwiftUI

@MainActor
protocol CoordinatorProtocol: AnyObject {
    func start()
    func stop()
    func toPresentable() -> AnyView
}

extension CoordinatorProtocol {
    func start() { }
    
    func stop() { }
    
    func toPresentable() -> AnyView {
        AnyView(Text("View not configured"))
    }
}
