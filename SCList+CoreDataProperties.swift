//
//  SCList+CoreDataProperties.swift
//  Listacular
//
//  Created by Will Zimmer on 12/15/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SCList {

    @NSManaged var sccross: NSNumber?
    @NSManaged var scdesc: String?
    @NSManaged var scitem: String?
    @NSManaged var scprice: String?
    @NSManaged var scqty: String?

}
