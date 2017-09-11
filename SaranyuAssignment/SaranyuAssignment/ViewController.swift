//
//  ViewController.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController {
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: WetherList.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

     var blockOperations: [BlockOperation] = []
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "WetherListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WetherListCollectionViewCell")
        collectionView.register(UINib(nibName: "HeaderViewCellCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderViewCellCollectionReusableView")
        updateCollectionContent()
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateCollectionContent() {
        
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(self.fetchedhResultController.sections?[0].numberOfObjects)")
        } catch let error  {
            print("ERROR: \(error)")
        }
        
        let service = APIService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                DispatchQueue.main.async {
                   //self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
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
//            let mediaDictionary = dictionary["media"] as? [String: AnyObject]
//            wetherEntity.mediaURL = mediaDictionary?["m"] as? String
            return wetherEntity
        }
        return nil
    }
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createPhotoEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
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
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(newIndexPath)")
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
            print("Delete Object: \(indexPath)")
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
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
            if let singleWether = fetchedhResultController.object(at: indexPath) as? WetherList {
                headerView.iboDate.text = "\(singleWether.date?.dayOfWeek() ?? "") \(singleWether.date?.dayNumber() ?? "") \(singleWether.date?.monthName() ?? "")"
                headerView.iboCityName.text = singleWether.name
                headerView.iboWetherType.text = singleWether.wetherType
                    headerView.iboHumidity.text = "\(singleWether.humidity)%"
                headerView.iboTemperature.text = "\(singleWether.temp.celsius())"
                headerView.iboMInAndMax.text = "\(singleWether.max.celsius())\u{00B0}/\(singleWether.min.celsius())\u{00B0}"
                
            }
            }
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
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // ofSize should be the same size of the headerView's label size:
        return CGSize(width: collectionView.frame.size.width, height: 500)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: 180)
    }
    
}

extension Date {
    /**
     Formats a Date
     
     - parameters format: (String) for eg dd-MM-yyyy hh-mm-ss
     */
    func format(format:String = "dd-MM-yyyy hh-mm-ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        if let newDate = dateFormatter.date(from: dateString) {
            return newDate
        } else {
            return self
        }
    }
}



