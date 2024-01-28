//
//  AppDelegate.swift
//  SwiftGrapher
//
//  Created by Eskil Gjerde Sviggum on 12/01/2024.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var equationManagementService: EquationManagementService
    var compilerService: SwiftCompilerService

    override init() {
        self.equationManagementService = EquationManagementServiceImpl()
        self.compilerService = SwiftCompilerServiceImpl()
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

