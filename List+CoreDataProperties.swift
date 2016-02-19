//
//  List+CoreDataProperties.swift
//  Listacular
//
//  Created by Will Zimmer on 1/31/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension List {

    @NSManaged var mpcalendar: NSNumber?
    @NSManaged var mpcross: NSNumber?
    @NSManaged var mpcategory: String?
    @NSManaged var mpdate: String?
    @NSManaged var mpitem: String?
    @NSManaged var mplist: NSNumber?
    @NSManaged var pcross: NSNumber?
    @NSManaged var pcategory: String?
    @NSManaged var pdesc: String?
    @NSManaged var pitem: String?
    @NSManaged var plist: NSNumber?
    @NSManaged var pminstepperlabel: String?
    @NSManaged var pminsteppervalue: NSNumber?
    @NSManaged var pprice: String?
    @NSManaged var pqty: String?
    @NSManaged var pqtystepperlabel: String?
    @NSManaged var psuffix: String?
    @NSManaged var sccross: NSNumber?
    @NSManaged var scdesc: String?
    @NSManaged var scitem: String?
    @NSManaged var sclist: NSNumber?
    @NSManaged var scprice: String?
    @NSManaged var scqty: String?
    @NSManaged var slcross: NSNumber?
    @NSManaged var slcategory: String?
    @NSManaged var sldesc: String?
    @NSManaged var slist: NSNumber?
    @NSManaged var slitem: String?
    @NSManaged var slminqty: String?
    @NSManaged var slprice: String?
    @NSManaged var slqty: String?
    @NSManaged var slsuffix: String?
    @NSManaged var tdcross: NSNumber?
    @NSManaged var tddate: String?
    @NSManaged var tddesc: String?
    @NSManaged var tditem: String?
    @NSManaged var tdlist: NSNumber?
    @NSManaged var tdtime: String?
    @NSManaged var rlist: NSNumber?
    @NSManaged var ritem: String?
    @NSManaged var ringredients: String?
    @NSManaged var rdirections: String?
    @NSManaged var rcross: NSNumber?

}
