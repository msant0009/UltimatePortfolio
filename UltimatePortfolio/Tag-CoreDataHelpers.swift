//
//  Tag-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/7/25.
//

import SwiftUI

extension Tag {
    var tagID: UUID {
        id ?? UUID()
    }
    
    var tagName: String {
        name ?? ""
    }
    
    static var example: Tag {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example Tag"
        
        return tag
    
    }
    
}
