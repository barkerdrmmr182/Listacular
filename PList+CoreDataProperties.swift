//
//  PList+CoreDataProperties.swift
//  Listacular
//
//  Created by Will Zimmer on 1/13/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PList {

    @NSManaged var pcross: NSNumber?
    @NSManaged var pdesc: String?
    @NSManaged var pitem: String?
    @NSManaged var pprice: String?
    @NSManaged var pqty: String?
    @NSManaged var qtystepperlabel: String?
    @NSManaged var minstepperlabel: String?
    @NSManaged var minsteppervalue: NSNumber?

}
