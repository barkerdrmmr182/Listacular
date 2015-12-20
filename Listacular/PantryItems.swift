//
//  PantryItems.swift
//  Listacular
//
//  Created by Will Zimmer on 12/20/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class PantryItems: UIViewController {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var pitem: UILabel!
    @IBOutlet weak var pdesc: UILabel!
    @IBOutlet weak var pqty: UILabel!
    @IBOutlet weak var pprice: UILabel!
    
    
    var item: PList? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            pitem.text = item?.pitem
            pdesc.text = item?.pdesc
            pqty.text = item?.pqty
            pprice.text = item?.pprice
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func dismissVC() {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    // Dispose of any resources that can be recreated.
    
    
    @IBAction func saveButton(sender: AnyObject) {
        
        if item != nil {
            edititems()
        } else {
            createitems()
        }
        
        
        dismissVC()
        
    }
    
    
    
    func createitems() {
        
        let entityDescripition = NSEntityDescription.entityForName("PList", inManagedObjectContext: moc)
        
        let item = PList(entity: entityDescripition!, insertIntoManagedObjectContext: moc)
        
        item.pitem = pitem.text
        item.pqty = pqty.text
        item.pdesc = pdesc.text
        item.pprice = pprice.text
        
        if pitem.text == nil{
            createitems()
            
        }else{
            edititems()
        }
        
        
        
        do {
            try moc.save()
        } catch _ {
            return
        }
    }
    func edititems() {
        item?.pitem = pitem.text!
        item?.pqty = pqty.text!
        item?.pdesc = pdesc.text!
        item?.pprice = pprice.text!
        
        
        do {
            try moc.save()
        } catch {
            return
        }
}
}