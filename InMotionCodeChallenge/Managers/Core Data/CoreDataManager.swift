//
//  CoreDataManager.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import Foundation
import CoreData

enum StorageType {
  case persistent, inMemory
}

class CoreDataManager: NSObject {
    convenience override init() {
        self.init(withStorageType: .persistent)
    }
    
    init(withStorageType storageType: StorageType){
        let container = NSPersistentContainer(name: "InMotionCodeChallenge")
        
        if storageType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        self.persistentContainer = container
    }
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer?
    
    // MARK: - Core Data Saving support
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentContainer!.viewContext
    }()
    
    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let newBGContext = persistentContainer!.newBackgroundContext()
        newBGContext.automaticallyMergesChangesFromParent = true
        newBGContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        newBGContext.undoManager = nil
        
        return newBGContext
    }()
    
    func saveViewContext() throws {
        let context = managedObjectContext
        if context.hasChanges {
            try context.save()
        } 
    }
    
    func saveBGContext() throws {
        let context = backgroundContext
        if context.hasChanges {
            try context.save()
        }
    }
}

