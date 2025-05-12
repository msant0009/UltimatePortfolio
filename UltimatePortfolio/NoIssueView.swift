//
//  NoIssueView.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/12/25.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue") {
            
            
        }
    }
}

#Preview {
    NoIssueView()
}
