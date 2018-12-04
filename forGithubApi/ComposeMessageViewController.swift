//
//  ComposeMessageViewController.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 12/2/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import IQKeyboardManagerSwift

class ComposeMessageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DeleteSecondScreenDelegate, UITextViewDelegate {
    
    @IBOutlet weak var curCollectionSecondView: UICollectionView!
    var numberOfChosen: Int!
    
    @IBOutlet weak var noUsersLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    var isEmptyTextView: Bool = false
    var dataArrayUsers: [User] = []
    @IBOutlet weak var curTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curCollectionSecondView.register(UINib(nibName: "SelectedUserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chosenUserCollectionCell")
        if #available(iOS 10.0, tvOS 10.0, *) {
            curCollectionSecondView?.prefetchDataSource = self
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUsersLocally()
        curCollectionSecondView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadUsersLocally() {
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        userFetch.predicate = NSPredicate(format: "chosen == 1")
        let nameSort = NSSortDescriptor(key: "id", ascending: true)
        userFetch.sortDescriptors = [nameSort]
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedUser = try managedObjectContext.fetch(userFetch) as? [User] ,
                fetchedUser.count > 0 {
                dataArrayUsers = fetchedUser
                numberOfChosen = dataArrayUsers.count
                if dataArrayUsers.count == 0 && (curTextView.text.lengthOfBytes(using: .utf8) == 0) {
                    sendButton.isEnabled = false
                } else {
                    sendButton.isEnabled = true
                }
                
                
            } else {
                dataArrayUsers.removeAll()
                numberOfChosen = dataArrayUsers.count
                sendButton.isEnabled = false
            }
            curCollectionSecondView.reloadData()
            
        } catch {
            fatalError("Failed to fetch user: \(error)")
        }
    }
    
    @objc func reloadTableUsers(notification:NSNotification) {
        reloadAll()
        
    }
    
    func reloadAll() {
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let sortDescriptors = [sortDescriptor]
        userFetch.sortDescriptors = sortDescriptors
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedUser = try managedObjectContext.fetch(userFetch) as? [User] ,
                fetchedUser.count > 0 {
                curCollectionSecondView.reloadData()
            } else {
                
            }
        } catch {
            fatalError("Failed to fetch user: \(error)")
        }
        
    }
    
    @IBAction func sendButtonClicked(_ sender: Any) {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent("diskCache")
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            if filePath.absoluteString.contains("jpg") {
                try? fileManager.removeItem(at: filePath)
            }
        }
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        deleteAllData("User")
        deleteAllData("Page")
        self.navigationController?.popViewController(animated: false)
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = true
        let managedObjectContext = CoredataStack.mainContext
        managedObjectContext.performAndWait { () -> Void in
            do {
                
                let results = try managedObjectContext.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else {continue}
                    managedObjectContext.delete(objectData)
                }
            } catch let error {
                print("Detele all data in \(entity) error :", error)
            }
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
        loadUsersLocally()
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if IQKeyboardManager.shared.keyboardShowing == true {
            self.view.endEditing(true)
        }
    }
    
    //MARK: - UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.lengthOfBytes(using: .utf8) > 0 &&
            dataArrayUsers.count > 0 {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    //MARK: - DeleteDelegate
    
    func deleteClick(tag: Int, userId: Int64) {
        let curIndex = IndexPath(row: tag, section: 0)
        if let curUser = dataArrayUsers[curIndex.row] as? User {
            curUser.chosen = !curUser.chosen
            let managedObjectContext = CoredataStack.mainContext
            
            managedObjectContext.performAndWait { () -> Void in                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
        }
        
        }
        loadUsersLocally()
        
    }
    
    //MARK: - collectionViewDelegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if dataArrayUsers.count > 0 {
            curCollectionSecondView.isHidden = false
        } else {
            curCollectionSecondView.isHidden = true
        }
        numberOfChosen = dataArrayUsers.count
        return numberOfChosen
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let curUser = dataArrayUsers[indexPath.row] as? User {
        let url = URL(string: "https://avatars2.githubusercontent.com/u/\(curUser.id)?v=4&client_id=\(ApiManager.shared.clientId)&client_secret=\(ApiManager.shared.cs).jpg")!
        
        _ = (cell as! SelectedUserCollectionViewCell).avatarImageView.kf.setImage(with: url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // This will cancel all unfinished downloading task when the cell disappearing.
        (cell as! SelectedUserCollectionViewCell).avatarImageView.kf.cancelDownloadTask()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chosenUserCollectionCell", for: indexPath) as! SelectedUserCollectionViewCell
        cell.delegateSecondScreenDelete = self
        cell.curCellIndex = indexPath
        cell.avatarImageView.kf.indicatorType = .activity
        if let curUser = dataArrayUsers[indexPath.row] as? User {
            cell.setWithUser(curUser)
        }
        
        return cell
    }
    
    

}

extension ComposeMessageViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap {
            URL(string: "https://avatars2.githubusercontent.com/u/\($0.row + 1)?v=4&client_id=\(ApiManager.shared.clientId)&client_secret=\(ApiManager.shared.cs).jpg")
        }
        
        ImagePrefetcher(urls: urls).start()
    }
}


// Inspired by: https://fdp.io/blog/2018/03/22/supporting-compactmap-in-swift-4/
#if swift(>=4.1)
// This is provided by the stdlib
#else
extension Sequence {
func compactMap<T>(_ transform: (Self.Element) throws -> T?) rethrows -> [T] {
return try flatMap(transform)
}
}
#endif
