//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/5/25.
//

import CoreData

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    private var saveTask: Task<Void, Error>?

    
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    var suggestedFilterTokens: [Tag] {
//        guard filterText.starts(with: "#") else {
//            return []
//        }
        
        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()
        
        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }
        
        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
        
    }
    
    func createSampleData() {
        let viewContext = container.viewContext
        
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.name = "Tag \(i)"
            tag.id = UUID()
            
            for j in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(i) - \(j)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
            
            
        }
        
        try? viewContext.save()
        
    }
    

    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
        
    }
    
    func queueSave() {
        saveTask?.cancel()
        
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
        
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        
        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        
        save()
        
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    func missingTags(from issue: Issue) ->[Tag]{
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagSet = Set(allTags)
        let difference = allTagSet.symmetricDifference(issue.issueTags)
        
        return difference.sorted()
        
    }
    

    
    func issuesForSelectedFilter() -> [Issue] {
        //old inefficient but simple method
//        let filter = selectedFilter ?? .all
//        var allIssues: [Issue]
//
//        if let tag = filter.tag {
//            allIssues = tag.issues?.allObjects as? [Issue] ?? []
//        } else {
//            let request = Issue.fetchRequest()
//            
//            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
//            
//            allIssues = (try? container.viewContext.fetch(request)) ?? []
//            
//        }
//        
//        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
//        
//        if trimmedFilterText.isEmpty == false {
//                allIssues = allIssues.filter {
//                    $0.issueTitle.localizedCaseInsensitiveContains(filterText) || $0.issueContent.localizedCaseInsensitiveContains(filterText)
//            }
//        }
    
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()
        
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        
        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        
        if filterTokens.isEmpty == false {
            let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterTokens)
            predicates.append(tokenPredicate)
        }
        
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
            
        return allIssues.sorted()
        
        
    }
    
    
    
}

