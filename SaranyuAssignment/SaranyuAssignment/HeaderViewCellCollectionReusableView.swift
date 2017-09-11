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
    
}
