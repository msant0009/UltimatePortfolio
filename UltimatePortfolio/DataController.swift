//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Mark Santoro on 5/5/25.
//

import CoreData

class DataController: ObservableObject {
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    
    
    let container: NSPersistentCloudKitContainer
    
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
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
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
    
    
    
}

