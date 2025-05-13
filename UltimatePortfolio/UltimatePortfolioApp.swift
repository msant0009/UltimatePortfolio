//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/5/25.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onChange(of: scenePhase) { oldValue, newValue in
                    if newValue != .active {
                        dataController.save()
                    }
                }
        }
    }
}
