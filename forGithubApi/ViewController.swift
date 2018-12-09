//
//  ViewController.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/25/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ChooseDelegate, DeleteDelegate {
    @IBOutlet weak var curTableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var numberOfUsers: Int! = 0
    @IBOutlet weak var curCollectionView: UICollectionView!
    var numberOfChosen: Int!
    var fetchedChosenResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    @IBOutlet weak var noUsersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        curTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userTableCell")
        curCollectionView.register(UINib(nibName: "SelectedUserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chosenUserCollectionCell")
        if #available(iOS 10.0, tvOS 10.0, *) {
            curTableView?.prefetchDataSource = self
            curCollectionView?.prefetchDataSource = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeFetchedResultsController()
        initializeFetchedChosenResultsController()
        loadUsersLocally()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadTableUsers(notification:)), name: NSNotification.Name(rawValue: "reloadUsers"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadUsers"), object: nil)
    }
    
    func loadUsersLocally() {
        let userFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let sortDescriptors = [sortDescriptor]
        userFetch.sortDescriptors = sortDescriptors
        do {
            let managedObjectContext = CoredataStack.mainContext
            if let fetchedUser = try managedObjectContext.fetch(userFetch) as? [User] ,
                fetchedUser.count > 0 {
                curTableView.reloadData()
                
                curCollectionView.reloadData()
                curCollectionView!.numberOfItems(inSection: 0)
            } else {
                let startPageValues = ["start_page":  Int64(1)]
                _ = Page.saveObject(values: startPageValues)
                
                ApiManager.shared.getUsers()
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
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
                curTableView.reloadData()
                curCollectionView.reloadData()
                curCollectionView!.numberOfItems(inSection: 0)
            } else {
                
            }
        } catch {
            fatalError("Failed to fetch region: \(error)")
        }
        
    }
    
    //MARK: - ChooseDelegate
    
    func chooseClick(tag: Int, userId: Int64) {
        let curIndex = IndexPath(row: tag, section: 0)
        if let curUser = self.fetchedResultsController?.object(at: curIndex) as? User {
            curUser.chosen = !curUser.chosen
            curUser.dateClicked = Date()
            let managedObjectContext = CoredataStack.mainContext
            managedObjectContext.performAndWait { () -> Void in
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
            initializeFetchedChosenResultsController()
        }
        
    }
    
    //MARK: - DeleteDelegate
    
    func deleteClick(tag: Int, userId: Int64) {
        if fetchedChosenResultsController?.fetchedObjects?.count ?? 0 > 0 {
            for curUs in (fetchedChosenResultsController?.fetchedObjects as! [User]) {
            if curUs.id == userId {
                curUs.chosen = !curUs.chosen
                curUs.dateClicked = nil
                let managedObjectContext = CoredataStack.mainContext
                managedObjectContext.performAndWait { () -> Void in
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                }
                initializeFetchedChosenResultsController()
            }
        }
        }
        
    }
    
    //MARK: - collectionViewDelegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // This will cancel all unfinished downloading task when the cell disappearing.
        (cell as! SelectedUserCollectionViewCell).avatarImageView.kf.cancelDownloadTask()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let curUser = fetchedChosenResultsController.object(at: indexPath) as? User {
            let url = URL(string: "https://avatars2.githubusercontent.com/u/\(curUser.id)?v=4&client_id=\(ApiManager.shared.clientId)&client_secret=\(ApiManager.shared.cs).jpg")!
            
            _ = (cell as! SelectedUserCollectionViewCell).avatarImageView.kf.setImage(with: url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedChosenResultsController.sections else {
            fatalError("No sections in fetchedChosenResultsController")
        }
        let sectionInfo = sections[section]
        print("sectionInfo.numberOfObjects = \(sectionInfo.numberOfObjects)")
        print("numberOfRowsInSection numberOfSectionsIn collectionView fetchedChosenResultsController.sections!.count = \(fetchedChosenResultsController.sections!.count)")
        if sectionInfo.numberOfObjects > 0 {
            curCollectionView.isHidden = false
        } else {
            curCollectionView.isHidden = true
        }
        numberOfChosen = sectionInfo.numberOfObjects
        return numberOfChosen
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chosenUserCollectionCell", for: indexPath) as? SelectedUserCollectionViewCell
            
            else {
            fatalError("Wrong cell type dequeued")
        }
        cell.delegateDelete = self
        cell.curCellIndex = indexPath
        
        if let curUser = self.fetchedChosenResultsController?.object(at: indexPath) as? User {
            cell.avatarImageView.kf.indicatorType = .activity
            cell.setWithUser(curUser)
        }
        
        return cell
    }
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(" section = \(section)")
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        print("sectionInfo.numberOfObjects = \(sectionInfo.numberOfObjects)")
        print("numberOfRowsInSection numberOfSectionsInTableView fetchedResultsController.sections!.count = \(fetchedResultsController.sections!.count)")
        if sectionInfo.numberOfObjects > 0 {
            curTableView.isHidden = false
        }
        numberOfUsers = sectionInfo.numberOfObjects
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSectionsInTableView fetchedResultsController.sections!.count = \(1)")
        return 1
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("didEndDisplaying \(indexPath)")
        (cell as! UserTableViewCell).avatarImageView.kf.cancelDownloadTask()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let curUser = self.fetchedResultsController?.object(at: indexPath) as? User {
        let url =
        URL(string: "https://avatars2.githubusercontent.com/u/\(curUser.id)?v=4&client_id=\(ApiManager.shared.clientId)&client_secret=\(ApiManager.shared.cs).jpg")!
        
        
        _ = (cell as! UserTableViewCell).avatarImageView.kf.setImage(with: url)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =
            tableView.dequeueReusableCell(withIdentifier: "userTableCell") as? UserTableViewCell
            
        
         else {
            fatalError("Wrong cell type dequeued")
        }
        cell.delegateChoose = self
        cell.curCellIndex = indexPath
        cell.avatarImageView.kf.indicatorType = .activity
        if let curUser = self.fetchedResultsController?.object(at: indexPath) as? User {
            
            cell.setWithUser(curUser)
        }
        print("indexPath = \(indexPath), numberOfUsers = \(String(describing: numberOfUsers))")
        var lastItemReached:Bool = false
        
        if numberOfUsers > 0 {
            let curUser = self.fetchedResultsController?.object(at: indexPath) as? User
            let curLastIndex = IndexPath(row: numberOfUsers - 1, section: indexPath.section)
            if let lastUser = (self.fetchedResultsController?.object(at: curLastIndex)) as? User,
                let lastUserId = lastUser.id as? Int64,
                let curUserId = curUser?.id ,
                (lastUserId == curUserId) {
                lastItemReached = true
            } else {
                lastItemReached = false
            }
            
        } else {
            lastItemReached = true
        }
        var curP = 0
        if Page.getCurrentPage() == 1 {
            curP = 1
        } else {
            curP = (Page.getCurrentPage() ?? 1) - 1
        }
        if lastItemReached && (numberOfUsers >= (ApiManager.pageSize)*curP) && indexPath.row == numberOfUsers - 1 {
            ApiManager.shared.getUsers()
        }        
        return cell
    }
    
    
    //MARK: - fetched controller
    
    func initializeFetchedChosenResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "chosen == YES")
        //let nameSort = NSSortDescriptor(key: "id", ascending: true)
        let dateClickedSort = NSSortDescriptor(key: "dateClicked", ascending: true)
        request.sortDescriptors = [dateClickedSort]
        let managedObjectContext = CoredataStack.mainContext
        fetchedChosenResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedChosenResultsController.delegate = self
        
        
        do {
            try fetchedChosenResultsController.performFetch()
            
        } catch {
            fatalError("Failed to initialize FetchedChosenResultsController: \(error)")
        }
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let nameSort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [nameSort]
        let managedObjectContext = CoredataStack.mainContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == fetchedResultsController {
            curTableView.beginUpdates()
        } else {
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("didChange sectionInfo type = \(type)")
        switch type {
        case .insert:
            if controller == fetchedResultsController {
                curTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            } else {
                self.curCollectionView?.performBatchUpdates({
                    curCollectionView.insertSections(IndexSet(integer: sectionIndex))
                    curCollectionView.reloadData()
                    curCollectionView!.numberOfItems(inSection: 0)
                }, completion: nil)
            }
        case .delete:
            if controller == fetchedResultsController {
                curTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            } else {
                self.curCollectionView?.performBatchUpdates({
                    curCollectionView.deleteSections(IndexSet(integer: sectionIndex))
                    curCollectionView.reloadData()
                    curCollectionView!.numberOfItems(inSection: 0)
                }, completion: nil)
            }
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("didChange indexPath type = \(type.rawValue)")
        switch type {
        case .insert:
            if controller == fetchedResultsController {
                curTableView.insertRows(at: [newIndexPath!], with: .fade)
            } else {
                    curCollectionView.insertItems(at: [newIndexPath!])
                    curCollectionView!.numberOfItems(inSection: 0)
            }
        case .delete:
            if controller == fetchedResultsController {                
                curTableView.deleteRows(at: [indexPath!], with: .fade)
            } else {
                if curCollectionView!.numberOfItems(inSection: 0) > 0  {
                    curCollectionView.deleteItems(at: [indexPath!])
                }
            }
        case .update:
            if controller == fetchedResultsController {
                curTableView.reloadRows(at: [indexPath!], with: .fade)
            } else {
                curCollectionView.reloadItems(at: [indexPath!])
            }
        case .move:
            if controller == fetchedResultsController {
                curTableView.moveRow(at: indexPath!, to: newIndexPath!)
            } else {
                curCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
            }
        }
        self.curCollectionView?.performBatchUpdates({
            curCollectionView.reloadData()
            curCollectionView.setNeedsDisplay()
        }, completion: nil)
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == fetchedResultsController {
            curTableView.endUpdates()
            reloadAll()
        } else {
            self.curCollectionView?.performBatchUpdates({
                curCollectionView.reloadData()
                curCollectionView!.numberOfItems(inSection: 0)
            }, completion: nil)
        }
    }


}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap {
            URL(string: "https://avatars2.githubusercontent.com/u/\($0.row + 1)?v=4&client_id=\(ApiManager.shared.clientId)&client_secret=\(ApiManager.shared.cs).jpg")
        }
        
        ImagePrefetcher(urls: urls).start()
    }
    
}

extension ViewController: UICollectionViewDataSourcePrefetching {
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

