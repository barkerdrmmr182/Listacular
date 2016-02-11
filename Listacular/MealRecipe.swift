//
//  MealRecipe.swift
//  Listacular
//
//  Created by Will Zimmer on 2/2/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class MealRecipe: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var recipe = [String]()
    
    var item: List? = nil
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        titleLabel.text = "test"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
