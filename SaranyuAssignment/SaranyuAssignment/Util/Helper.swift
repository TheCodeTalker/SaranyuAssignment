//
//  Helper.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 12/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import Foundation

extension Date {
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



extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    func monthName() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d. MMMM"
        return dateFormatter.string(from: self)
    }
}


extension Double{
    func celsius() -> String {
        let celsius = (self)
        return String(format: "%.0f", celsius)
        
    }
}
