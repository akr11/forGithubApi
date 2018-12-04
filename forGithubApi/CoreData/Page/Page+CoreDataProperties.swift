//
//  Page+CoreDataProperties.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/26/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//
//

import Foundation
import CoreData


extension Page {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged public var id: Int64
    @NSManaged public var start_page: Int64
    @NSManaged public var total_count: Int64
    @NSManaged public var lastSeenUserId: Int64

}
