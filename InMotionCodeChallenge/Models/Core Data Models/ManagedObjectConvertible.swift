//
//  ManagedObjectConvertible.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//
// From code found at https://nicolasbichon.com/creating-an-abstraction-layer-for-the-model/

import Foundation
import CoreData


// protocol to be implemented by and NSManagedObject objects that will be converted to NSObject
protocol ManagedObjectConvertible {
    /// An object which should implement the `ObjectConvertible` protocol.
    associatedtype T

    /// A String representing a URI that provides an archiveable reference to the object in Core Data.
    var identifier: String? { get }

    /// Insert an object in Core Data.
    ///
    /// - Parameters:
    ///   - object: The object to insert.
    ///   - context: The managed object context.
    static func insert(_ object: T, with context: NSManagedObjectContext) throws

    /// Update an object in Core Data.
    ///
    /// - Parameters:
    ///   - object: The object to update.
    ///   - context: The managed object context.
    static func update(_ object: T, with context: NSManagedObjectContext) throws

    /// remove an object from Core Data.
    ///
    /// - Parameters:
    ///   - object: The object to remove.
    ///   - context: The managed object context.
    static func remove(_ object: T, with context: NSManagedObjectContext) throws

    /// Fetch all objects from Core Data.
    ///
    /// - Parameter context: The managed object context.
    /// - Parameter withSortDescriptors: Optional array for sort descrtors to apply when fetching  iobject array
    /// - Returns: A list of objects.
    static func fetchAll(from context: NSManagedObjectContext, withSortDescriptors sortDescriptors:[NSSortDescriptor]) -> [T]
    
    /// Remove all objects from Core Data.
    ///
    /// - Parameter context: The managed object context.
    static func removeAll(from context: NSManagedObjectContext) throws

    /// Set the managed object's parameters with an object's parameters.
    ///
    /// - Parameter object: An object.
    func from(object: T)

    /// Create an object, populated with the managed object's properties.
    ///
    /// - Returns: An object.
    func toObject() -> T
}

extension ManagedObjectConvertible where T: ObjectConvertible, Self: NSManagedObject {
    var identifier: String? {
        return objectID.uriRepresentation().absoluteString
    }

    static func insert(_ object: T, with context: NSManagedObjectContext) throws {
        guard object.identifier == nil else { return }

        let managedObject = Self(context: context)
        managedObject.from(object: object)

        try context.save()
    }

    static func update(_ object: T, with context: NSManagedObjectContext) throws {
        guard let managedObject = get(object: object, with: context) else {
            return
        }

        managedObject.from(object: object)

        try context.save()
    }

    static func remove(_ object: T, with context: NSManagedObjectContext) throws {
        guard let managedObject = get(object: object, with: context) else {
            return
        }

        context.delete(managedObject)

        try context.save()
    }

    static func fetchAll(from context: NSManagedObjectContext, withSortDescriptors sortDescriptors:[NSSortDescriptor] = []) -> [T]  {
        let request = NSFetchRequest<Self>(entityName: String(describing: self))
        request.sortDescriptors = sortDescriptors
        request.returnsObjectsAsFaults = false

        do {
            let managedObjects = try context.fetch(request)
            return managedObjects.map { $0.toObject() }
        } catch {
            return [T]()
        }
    }
    
    static func removeAll(from context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: String(describing: self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try context.execute(deleteRequest)
        
        try context.save()
    }

    private static func get(object: T, with context: NSManagedObjectContext) -> Self? {
        guard
            let identifier = object.identifier,
            let uri = URL(string: identifier),
            let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else
        {
            return nil
        }

        do {
            return try context.existingObject(with: objectID) as? Self
        } catch {
            return nil
        }
    }
}


