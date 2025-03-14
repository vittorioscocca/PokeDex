//
//  PokeDexUITestsLaunchTests.swift
//  PokeDexUITests
//
//  Created by vscocca on 10/03/25.
//

import XCTest

final class PokeDexUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Inserisci eventuali passaggi da eseguire dopo il lancio dell'app,
        // ad esempio effettuare il login o navigare in una specifica area dell'app
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
