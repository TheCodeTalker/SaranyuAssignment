//
//  HeaderViewCellCollectionReusableView.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import UIKit

class HeaderViewCellCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var iboMInAndMax: UILabel!
    @IBOutlet weak var iboHumidity: UILabel!
    @IBOutlet weak var iboWetherType: UILabel!
    @IBOutlet weak var iboTemperature: UILabel!
    @IBOutlet weak var iboDate: UILabel!
    @IBOutlet weak var iboCityName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configHeader(singleWether: WetherList) {
        iboDate.text = "\(singleWether.date?.dayOfWeek() ?? ""),  \(singleWether.date?.monthName() ?? "")"
        iboCityName.text = singleWether.name
        iboWetherType.text = singleWether.wetherType
        iboHumidity.text = "\(singleWether.humidity)%"
        iboTemperature.text = "\(singleWether.temp.celsius())\u{00B0}"
        iboMInAndMax.text = "\(singleWether.max.celsius())\u{00B0}/\(singleWether.min.celsius())\u{00B0}"
    }
    
}
