//
//  ViewController.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView
class ViewController: UIViewController,NVActivityIndicatorViewable {
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: WetherList.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

     var blockOperations: [BlockOperation] = []
    @IBOutlet weak var collectionView: UICollectionView!
    //MARK: - View Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
            self.viewSetup()
    }
    //MARK: - View Setup
    func viewSetup() {
        collectionView.register(UINib(nibName: "WetherListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WetherListCollectionViewCell")
        collectionView.register(UINib(nibName: "HeaderViewCellCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderViewCellCollectionReusableView")
        startAnimating(CGSize(width: 30, height: 30), message: "Please wait...", type: NVActivityIndicatorType(rawValue: 30)!)
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red: 66/255, green: 180/255, blue: 255/255, alpha: 1), UIColor(red: 173/255, green: 231/255, blue: 251/255, alpha: 1)]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.collectionView.backgroundView?.layer.insertSublayer(gradient, at: 0)
        
        updateCollectionContent()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - make api call and clear core data
    func updateCollectionContent() {
        
        do {
            try self.fetchedhResultController.performFetch()
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                    self.stopAnimating()
                }
            case .Error(let message):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - insert into coredata
    
    private func createPhotoEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let wetherEntity = NSEntityDescription.insertNewObject(forEntityName: "WetherList", into: context) as? WetherList {
            wetherEntity.name = dictionary["name"] as? String
            wetherEntity.date = Date().format()
             let temp = dictionary["main"] as? [String:AnyObject]
            wetherEntity.temp = temp?["temp"] as! Double
            
            wetherEntity.humidity = temp?["humidity"]  as! Double
            wetherEntity.min = temp?["temp_min"] as! Double
            wetherEntity.max = temp?["temp_max"] as! Double
            let weatherType = dictionary["weather"] as? [[String:AnyObject]]
            wetherEntity.wetherType = weatherType?.first?["main"] as? String
            return wetherEntity
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 48/255, green: 151/255, blue: 187/255, alpha: 1)
    }
    
    //MARK: - save
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createPhotoEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    //MARK: - deinit
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    //MARK: - clear coredata
    
    private func clearData() {
        do {
            
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: WetherList.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }


}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    
    //MARK: -The fetched results controller reports changes 
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(newIndexPath ?? IndexPath(item: 0, section: 0))")
            if (collectionView?.numberOfSections)! > 0 {
                    blockOperations.append(
                        BlockOperation(block: { [weak self] in
                            if let this = self {
                                DispatchQueue.main.async {
                                    this.collectionView!.insertItems(at: [newIndexPath!])
                                }
                            }
                        })
                    )
                
                
            }
        }
 

        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(indexPath ?? IndexPath(item: 0, section: 0))")
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.collectionView!.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
    }
    
    //MARK: - Notifies the receiver that the fetched results controller has completed processing
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
            self.collectionView.reloadData()
            blockOperations.removeAll(keepingCapacity: false)
    }
    
    }

extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects  , count > 0 {
            return count
        }
        return 0

    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "HeaderViewCellCollectionReusableView",
                                                                             for: indexPath) as! HeaderViewCellCollectionReusableView
            
            if self.fetchedhResultController.sections?[0].numberOfObjects ?? 0 > 0{
            if let singleWether = fetchedhResultController.object(at: indexPath) as? WetherList {headerView.configHeader(singleWether: singleWether)}}
            return headerView
        default:
            fatalError("this is NOT should happen!!")
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WetherListCollectionViewCell", for: indexPath) as! WetherListCollectionViewCell
        if let singleWether = fetchedhResultController.object(at: indexPath) as? WetherList {
            cell.configCell(wether: singleWether)
        }
        return cell
    }
    
}
extension Collection where Indices.Iterator.Element == Index {
    
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 500)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: 180)
    }
    
}


