//
//  User+CoreDataProperties.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/29/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var avatar_url: String?
    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var created_at: String?
    @NSManaged public var email: String?
    @NSManaged public var followers: Int64
    @NSManaged public var following: Int64
    @NSManaged public var id: Int64
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var public_gists: String?
    @NSManaged public var public_repos: Int64
    @NSManaged public var url_details: String?
    @NSManaged public var chosen: Bool

}
