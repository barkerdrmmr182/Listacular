//
//  List.swift
//  Listacular
//
//  Created by Will Zimmer on 1/24/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import Foundation
import CoreData


class List: NSManagedObject {
    
    
    
    func sectionIdentifier() -> String {
    if self.slist == true {
        if self.slcross == true {
            return "True"
        } else {
            return "\(self.slcategory!)"
        }
    } else {
    return "false"
    }
    }


// Insert code here to add functionality to your managed object subclass

}
