//
//  WetherList+CoreDataProperties.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//

import Foundation
import CoreData


extension WetherList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WetherList> {
        return NSFetchRequest<WetherList>(entityName: "WetherList")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var temp: Double
    @NSManaged public var wetherType: String?
    @NSManaged public var min: Double
    @NSManaged public var max: Double
    @NSManaged public var humidity: Double

}
