//
//  Page+CoreDataClass.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/26/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Page)
public class Page: NSManagedObject {
    
    class func saveObject(values: Dictionary<String, Int64>) -> Page? {
        var pageObject: Page? = nil
        
        let recordId: Int64 = 1
        pageObject = self.getOrCreate(id: Int64(recordId))
        
        guard let resultObject = pageObject else {
            return pageObject
        }
        
        if let totalCount = values["total_count"] {
            resultObject.total_count = totalCount
        }
        if let lastSeenUserId = values["lastSeenUserId"] {
            resultObject.lastSeenUserId = lastSeenUserId
        }
        
        if let startPage = values["start_page"] {
            resultObject.start_page = startPage
        }
        let managedObjectContext = CoredataStack.mainContext
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error)
        }
        return resultObject
        
    }
    
    class func getOrCreate(id: Int64) -> Page? {
        let pageFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Page")
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedPage = try managedObjectContext.fetch(pageFetch) as? [Page] ,
                fetchedPage.count > 0 {
                let pageEntity = fetchedPage[0]
                return pageEntity
            } else {
                let curPage = NSEntityDescription.insertNewObject(forEntityName: "Page", into: managedObjectContext) as? Page
                curPage?.id = 1
                curPage?.start_page = 0
                do {
                    try managedObjectContext.save()
                } catch let error {
                    print(error)
                }

                return curPage
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
        }
    }
    
    class func getCurrentPage() -> Int? {
        
        let pageFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Page")
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedPage = try managedObjectContext.fetch(pageFetch) as? [Page] ,
                fetchedPage.count > 0 {
                let pageEntity = fetchedPage[0]
                if let start = Int(pageEntity.start_page) as? Int {
                    return start
                }
            } else {
                return 0
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
        }
    
    
    }

}
