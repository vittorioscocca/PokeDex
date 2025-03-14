//
//  NavigationStackCoordinator.swift
//  PokeDex
//
//  Created by vscocca on 13/03/25.
//


import Combine
import SwiftUI

/// Class responsible for displaying a normal "NavigationController" style hierarchy
class NavigationStackCoordinator: ObservableObject, CoordinatorProtocol, CustomStringConvertible {
    
    @Published var rootModule: NavigationModule? {
        didSet {
            if let oldValue {
                self.logPresentationChange("Remove root", oldValue)
                oldValue.tearDown()
            }
            
            if let rootModule {
                self.logPresentationChange("Set root", rootModule)
                rootModule.coordinator?.start()
            }
        }
    }
    
    // The stack's current root coordinator
    var rootCoordinator: (any CoordinatorProtocol)? {
        self.rootModule?.coordinator
    }
    
    @Published var sheetModule: NavigationModule? {
        didSet {
            if let oldValue {
                self.logPresentationChange("Remove sheet", oldValue)
                oldValue.tearDown()
            }
            
            if let sheetModule {
                self.logPresentationChange("Set sheet", sheetModule)
                sheetModule.coordinator?.start()
            }
        }
    }
    
    var presentationDetents: Set<PresentationDetent> = []
    
    // The currently presented sheet coordinator
    // Sheets will be presented through the NavigationSplitCoordinator if provided
    var sheetCoordinator: (any CoordinatorProtocol)? {
        return self.sheetModule?.coordinator
    }
    
    @Published var fullScreenCoverModule: NavigationModule? {
        didSet {
            if let oldValue {
                self.logPresentationChange("Remove fullscreen cover", oldValue)
                oldValue.tearDown()
            }
            
            if let fullScreenCoverModule {
                self.logPresentationChange("Set fullscreen cover", fullScreenCoverModule)
                fullScreenCoverModule.coordinator?.start()
            }
        }
    }
    
    // The currently presented fullscreen cover coordinator
    var fullScreenCoverCoordinator: (any CoordinatorProtocol)? {
        return self.fullScreenCoverModule?.coordinator
    }
    
    @Published var stackModules = [NavigationModule]() {
        didSet {
            let diffs = self.stackModules.difference(from: oldValue)
            diffs.forEach { change in
                switch change {
                case .insert(_, let module, _):
                    self.logPresentationChange("Push", module)
                    module.coordinator?.start()
                case .remove(_, let module, _):
                    self.logPresentationChange("Pop", module)
                    module.tearDown()
                }
            }
        }
    }
    
    // The current navigation stack. Excludes the rootCoordinator
    var stackCoordinators: [any CoordinatorProtocol] {
        self.stackModules.compactMap(\.coordinator)
    }
    
    /// If this NavigationStackCoordinator will be embedded into a NavigationSplitCoordinator pass it here
    /// so that sheet presentations are done through it. Otherwise sheets will not be presented properly
    /// and dismissed automatically in compact layouts
    /// - Parameter navigationSplitCoordinator: The expected parent NavigationSplitCoordinator
    init() {
    }
    
    /// Set the coordinator to be used on the stack's root
    /// - Parameters:
    ///   - coordinator: the root coordinator
    ///   - animated: whether to animate the transition or not. Default is true
    ///   - dismissalCallback: called when this root coordinator has removed/replaced
    func setRootCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            self.rootModule = nil
            return
        }
        
        if self.rootModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }
        
        self.popToRoot(animated: false)
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.rootModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    /// Pushes a new coordinator on the navigation stack
    /// - Parameters:
    ///   - coordinator: the coordinator to be displayed
    ///   - animated: whether to animate the transition or not. Default is true
    ///   - dismissalCallback: called when the coordinator has been popped, programatically or otherwise
    func push(_ coordinator: any CoordinatorProtocol, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.stackModules.append(NavigationModule(coordinator, dismissalCallback: dismissalCallback))
        }
    }
    
    /// Pop all the coordinators from the stack, returning to the root coordinator
    /// - Parameter animated: whether to animate the transition or not. Default is true
    func popToRoot(animated: Bool = true) {
        guard !stackModules.isEmpty else {
            return
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.stackModules.removeAll()
        }
    }
    
    /// Removes the last coordinator from the navigation stack
    /// - Parameter animated: whether to animate the transition or not. Default is true
    func pop(animated: Bool = true) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            _ = self.stackModules.popLast()
        }
    }
    
    /// Present a sheet on top of the stack. If this NavigationStackCoordinator is embedded within a NavigationSplitCoordinator
    /// then the presentation will be proxied to the split
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - animated: whether to animate the transition or not. Default is true
    
    ///   - dismissalCallback: called when the sheet has been dismissed, programatically or otherwise
    func setSheetCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            self.sheetModule = nil
            return
        }
        
        if self.sheetModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.sheetModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    /// Present a fullscreen cover on top of the stack. If this NavigationStackCoordinator is embedded within a NavigationSplitCoordinator
    /// then the presentation will be proxied to the split
    /// - Parameters:
    ///   - coordinator: the coordinator to display
    ///   - animated: whether to animate the transition or not. Default is true
    ///   - dismissalCallback: called when the fullscreen cover has been dismissed, programatically or otherwise
    func setFullScreenCoverCoordinator(_ coordinator: (any CoordinatorProtocol)?, animated: Bool = true, dismissalCallback: (() -> Void)? = nil) {
        guard let coordinator else {
            self.fullScreenCoverModule = nil
            return
        }
        
        if self.fullScreenCoverModule?.coordinator === coordinator {
            fatalError("Cannot use the same coordinator more than once")
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            self.fullScreenCoverModule = NavigationModule(coordinator, dismissalCallback: dismissalCallback)
        }
    }
    
    // MARK: - CoordinatorProtocol
    
    func toPresentable() -> AnyView {
        AnyView(NavigationStackCoordinatorView(navigationStackCoordinator: self)
            .presentationDetents(presentationDetents))
    }
    
    /// The NavigationStack has a tendency to hold on to path items for longer than needed. We work around that by manually nilling the coordinator
    /// when a NavigationModule is dismissed. As the NavigationModule is just a wrapper multiple instances of it continuing living is of no consequence
    /// https://stackoverflow.com/questions/73885353/found-a-strange-behaviour-of-state-when-combined-to-the-new-navigation-stack/
    func stop() {
        self.rootModule?.tearDown()
        self.sheetModule?.tearDown()
        self.fullScreenCoverModule?.tearDown()
        
        self.stackModules.forEach { module in
            module.tearDown()
        }
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        if let rootCoordinator = rootModule?.coordinator {
            return "NavigationStackCoordinator(\(rootCoordinator))"
        } else {
            return "NavigationStackCoordinator(Empty)"
        }
    }
    
    // MARK: - Private
    
    private func logPresentationChange(_ change: String, _ module: NavigationModule) {
        if let coordinator = module.coordinator {
            print("\(self) \(change): \(coordinator)")
        }
    }
}

private struct NavigationStackCoordinatorView: View {
    @ObservedObject var navigationStackCoordinator: NavigationStackCoordinator
    
    var body: some View {
        NavigationStack(path: self.$navigationStackCoordinator.stackModules) {
            self.navigationStackCoordinator.rootModule?.coordinator?.toPresentable()
                .navigationDestination(for: NavigationModule.self) { module in
                    module.coordinator?.toPresentable()
                }
        }
        .sheet(item: self.$navigationStackCoordinator.sheetModule) { module in
            module.coordinator?.toPresentable()
        }
        .fullScreenCover(item: self.$navigationStackCoordinator.fullScreenCoverModule) { module in
            module.coordinator?.toPresentable()
        }
    }
}
