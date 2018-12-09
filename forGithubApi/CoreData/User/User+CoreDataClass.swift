//
//  User+CoreDataClass.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/29/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(User)
public class User: NSManagedObject {
    
    class func saveObject(json: JSON, chosen: Bool) -> User? {
        var userObject: User? = nil
        
        if let userId = json["id"].int64 {
            userObject = getOrCreate(id: userId)
        }
        
        userObject?.chosen = chosen
        
        guard let resultObject = userObject else {
            return userObject
        }
        
        resultObject.dateClicked = nil
                
        if let details = json["url"].string {
            resultObject.url_details = details
        }
        
        if let name = json["name"].string {
            resultObject.name = name
        }
        
        if let email = json["email"].string {
            resultObject.email = email
        }
        
        if let avatar = json["avatar_url"].string {
            resultObject.avatar_url = avatar
        }
        
        if let date = json["created_at"].string {
            let cropZ = date.replacingOccurrences(of: "Z", with: "", options: .literal, range:nil)
            let cropT = cropZ.replacingOccurrences(of: "T", with: " ", options: .literal, range:nil)
            
            resultObject.created_at = cropT
        }
        
        if let company = json["company"].string {
            resultObject.company = company
        }
        
        if let followers = json["followers"].int64 {
            resultObject.followers = followers
        }
        
        if let following = json["following"].int64 {
            resultObject.following = following
        }
        
        if let location = json["location"].string {
            resultObject.location = location
        }
        
        if let blog = json["blog"].string {
            resultObject.blog = blog
        }
        
        if let publicRepos = json["public_repos"].int64 {
            resultObject.public_repos = publicRepos
        }
        
        if let publicGists = json["public_gists"].string {
            resultObject.public_gists = publicGists
        }
        let managedObjectContext = CoredataStack.mainContext
        managedObjectContext.performAndWait { () -> Void in
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        }
        /*do {
            try managedObjectContext.save()
        } catch let error {
            print(error)
        }*/
        return resultObject
        
    }
    
    class func getOrCreate(id: Int64) -> User? {
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "id == %@  ", argumentArray: [id] )
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedUser = try managedObjectContext.fetch(userFetch) as? [User] ,
                fetchedUser.count > 0 {
                let userEntity = fetchedUser[0]
                return userEntity
            } else {
                let curUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as? User
                curUser?.id = id
                curUser?.chosen = false
                /*do {
                    try managedObjectContext.save()
                } catch let error {
                    print(error)
                }*/
                
                return curUser
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
        }
    }
    
    class func setChosen(idUser: Int64, chosenTrue: Bool) -> Bool{
        var userObject: User? = nil
        
        userObject = getOrCreate(id: idUser)
        userObject?.chosen = chosenTrue
        let managedObjectContext = CoredataStack.mainContext
        do {
            try managedObjectContext.save()
            return true
        } catch let error {
            print(error)
            return false
        }
        
       
        
        
        
    }
    
}

