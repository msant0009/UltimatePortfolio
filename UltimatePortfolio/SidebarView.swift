//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/6/25.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilters: [Filter] = [.all, .recent]
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    var tagFilters: [Filter] {
        tags.map {tag in
            Filter(id: tag.id ?? UUID(), name: tag.name ?? "No name", icon: "tag", tag: tag)
        }
    }

    
    
    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter){
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }//end section1
            
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter){
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
                
            }//end section2
        }
        .toolbar {
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
            
        }
    }// end body
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
        
}
