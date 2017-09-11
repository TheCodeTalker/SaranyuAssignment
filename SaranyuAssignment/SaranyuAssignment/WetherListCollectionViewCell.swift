//
//  WetherListCollectionViewCell.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import UIKit

class WetherListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iboMinandMax: UILabel!
    @IBOutlet weak var iboWetherIcon: UIImageView!
    @IBOutlet weak var iboCityNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(wether: WetherList)
    {
        self.iboCityNameLabel.text = wether.name
        //self.iboWetherIcon.image =
        self.iboMinandMax.text = "\(wether.max.celsius())\u{00B0}/\(wether.min.celsius())\u{00B0}"
        if wether.wetherType == "Clouds"{
            self.iboWetherIcon.image = UIImage(named: "cloud 1")
        }else if  wether.wetherType == "Clear"{
            
        }else if wether.wetherType == "Rain"{
             self.iboWetherIcon.image = UIImage(named: "cloud2")
            
        }
    }

}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
        // or capitalized(with: locale)
    }
    func monthName() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
        // or capitalized(with: locale)
    }
    func dayNumber() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD"
        return dateFormatter.string(from: self)
    }
}


extension Double{
    func celsius() -> String {
        let celsius = (self - 32.0) * (5.0/9.0)
        return String(format: "%.0f", celsius)
        
    }
}

