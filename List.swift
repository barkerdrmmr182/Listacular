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
    
    }else{
        if self.plist == true{
            if self.pcross == true {
                return "True"
            } else {
                return "\(self.pcategory!)"
            }
    }else{
        if self.mplist == true{
            if self.mpcross == true {
                return "True"
            } else {
                return "\(self.mpcategory!)"
            }
    }else{
        if self.rlist == true {
                if self.rcross == true {
                    return "True"
                } else {
                    return "\(self.mpcategory!)"
                }
    }else{
        if tdlist == true {
                    if self.tdcross == true {
                        return "True"
                    } else {
                        return "\(self.tddate!)"
                    }

                }else{
            return "false"
                }
            }
        }
        }
        }
    }
    
    
//    func mealSectionIdentifier() -> String {
//        if self.mplist == true {
//            if self.mpcross == true {
//                return "True"
//            } else {
//                return "\(self.mpcategory!)"
//            }
//        } else {
//            return "false"
//        }
//        }
    

//    func tdSectionIdentifier() ->String {
//        if self.tdlist == true {
//            if self.tdcross == true {
//                return "True"
//            } else{
//                return "\(self.tddate!)"
//            }
//        }else{
//            return "false"
//        }
//    }


// Insert code here to add functionality to your managed object subclass

}
