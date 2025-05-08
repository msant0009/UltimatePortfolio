//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/7/25.
//

import SwiftUI

extension Issue {
    var issueTitle: String {
        get { title ?? ""}
        set { title = newValue}
    }
    
    var issueContent: String {
        get { content ?? ""}
        set { content = newValue}
    }
   
    var issueCreationDate: Date {
        creationDate ?? .now
    }
    
    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        
        return issue
    
    }
    
    
    
    
    
}
