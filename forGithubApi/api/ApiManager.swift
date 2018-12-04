//
//  ApiManager.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/25/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//

import Alamofire
import CoreData
import SwiftyJSON

let apiUrl      = "https://api.github.com"
let search   = "search/users?q=language:java&sort=stars&order=desc&page"
let since = "users?since"
let detailUser  = "users"




class ApiManager {
    let clientId    = ""
    let cs          = ""
    
    var resultsCount: Int = 0
    static let pageSize: Int = 30
    
    static let shared : ApiManager = {
        let instance = ApiManager()
        
        return instance
    } ()
    
    func getUsers() {
        var urlString = ""
        
        if let currentPage = getCurrentPage() {
            //let startPage   = currentPage.start_page
            let lastSeenUserId   = currentPage.lastSeenUserId
            if lastSeenUserId == 0 {
                urlString = String(format: "%@/%@=%d&client_id=%@&client_secret=%@", apiUrl, since, 0,  clientId, cs)
            } else {
                urlString = String(format: "%@/%@=%d&client_id=%@&client_secret=%@", apiUrl, since, lastSeenUserId,  clientId, cs)
            }
            
        } else {
            return
        }
        guard let url = URL(string: urlString) else {
            return
        }
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let result = response.result.value as? Array<Dictionary<String, AnyObject>>//[AnyObject]
                {
                    
                    
                    self.resultsCount   = 0
                    let itemsJsonArray = result
                    
                    if itemsJsonArray.count > 0 {
                        var lastSeenUserId: Int64 = 1
                        var arUrlUsers = Array<String>()
                        
                        
                        for curUser in itemsJsonArray {
                            if let url = curUser["url"] as? String {
                                arUrlUsers.append(url)
                            }
                            if let lastSeen = (curUser["id"]) as? Int64 {
                                lastSeenUserId = lastSeen
                            }
                        }
                        self.downloadDetails(arUrlUsers) { downloaded in
                            // initiate whatever you want when the downloads are done
                            
                            print("All Done! \(downloaded) NSManagedObjectContextObjectsDidChangeNotification")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadUsers"), object: nil, userInfo: nil)
                        }
                                                 self.savePageAfterUsers(lastSeenUserId: lastSeenUserId)
                        
                        
                    }
                   
                    
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getCurrentPage()->Page? {
        let pageFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Page")
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedPage = try managedObjectContext.fetch(pageFetch) as? [Page] ,
                fetchedPage.count > 0 {
                let pageEntity = fetchedPage[0]
                return pageEntity
            } else {
                return nil
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
        }
    }
    
    func savePageAfterUsers(lastSeenUserId: Int64) {
        var currentPages: Page?
        
        let pageFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Page")
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedPage = try managedObjectContext.fetch(pageFetch) as? [Page] ,
                fetchedPage.count > 0 {
                let pageEntity = fetchedPage[0]
                currentPages = pageEntity
                
            } else {
                
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
        }
        var startPage   = -1
        
        if var start   = currentPages?.start_page {
            start   += Int64(1)
            startPage = Int(start)
        }
        let pageValues = ["start_page": Int64(startPage), "lastSeenUserId": lastSeenUserId]
        
        
        _ = Page.saveObject(values: pageValues)
    }
    
    func downloadDetails(_ details: [String], completionHandler: @escaping (Int) -> ()) {
        let group = DispatchGroup()
        
        var downloaded = 0
        
        group.notify(queue: .main) {
            completionHandler(downloaded)
        }
        
        for serverFile in details {
            group.enter()
            
            print("Start downloading \(serverFile)")
            
            downloadDetailForOneUser(serverFile: serverFile) { error in
                defer { group.leave() }
                
                if error == nil {
                    downloaded += 1
                }
            }
        }
    }
    
    
    
    private func downloadDetailForOneUser(serverFile: String, completionHandler: @escaping (NSError?)->()) {
        
        
        let forIncreaseApiRequestNumberPerHour = String(format: "%@?client_id=%@&client_secret=%@", serverFile, clientId, cs)
        guard let url = URL(string: forIncreaseApiRequestNumberPerHour) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("application/json"),
                let data = data, error == nil
                
                else {  if (error?.localizedDescription) != nil {
                    print((error?.localizedDescription)! as String)
                    }
                    return
            }
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                
                if json.count > 0 {
                    let objectForSaving = JSON(json)
                    
                    _ = User.saveObject(json: objectForSaving, chosen: false)
                    
                    completionHandler(nil)
                } else {
                    completionHandler(nil)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
                completionHandler(error)
            }
            }.resume()
    }
    
 
}

