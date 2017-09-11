//
//  ViewController.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "WetherListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WetherListCollectionViewCell")
        collectionView.register(UINib(nibName: "HeaderViewCellCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderViewCellCollectionReusableView")
        //self.collectionView.collectionViewLayout.header
        //self.collectionView.collectionViewLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width , height: 500)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "HeaderViewCellCollectionReusableView",
                                                                             for: indexPath) as! HeaderViewCellCollectionReusableView
            
            //headerView.lblTitle.text = myText
            //headerView.backgroundColor = UIColor.lightGray
            
            return headerView
        default:
            fatalError("this is NOT should happen!!")
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WetherListCollectionViewCell", for: indexPath)
        
       // cell.backgroundColor = UIColor.brown
        
        return cell
    }
    

    
    
    
    
}

extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // ofSize should be the same size of the headerView's label size:
        return CGSize(width: collectionView.frame.size.width, height: 500)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/2, height: 130)
    }
    
}



