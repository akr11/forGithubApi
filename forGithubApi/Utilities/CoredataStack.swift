//
//  CoredataStack.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/26/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//

import CoreData

internal let CoreData = CoredataStack.default

@available(iOS 10.0, *)
final class CoredataStack {
    // MARK: - Core Data stack
    
    
    static let `default` = CoredataStack()
    private init() {}
    
    static var container: NSPersistentContainer {
        return CoredataStack.default.persistentContainer
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "forGithubApi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                if let url = storeDescription.url {
                    try? FileManager.default.removeItem(at: url)
                    abort()
                }
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var viewContext: NSManagedObjectContext {
        return CoreData.persistentContainer.viewContext
    }
    
    static var mainContext: NSManagedObjectContext {
        return CoreData.persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data Saving support
    static func saveContext() {
        CoreData.saveContext()
    }
    
    func saveContext() {
        DispatchQueue.main.async {
            let context = self.persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}

