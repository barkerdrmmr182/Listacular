//
//  SLEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class SLEdit: UIViewController {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var slitem: UITextField!
    @IBOutlet weak var sldesc: UITextField!
    @IBOutlet weak var slqty: UITextField!
    @IBOutlet weak var slprice: UITextField!
    
    
    
    var item: SList? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            slitem.text = item?.slitem
            sldesc.text = item?.sldesc
            slqty.text = item?.slqty
            slprice.text = item?.slprice
        }
        
        // "x" Delete Feature
        self.slitem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.sldesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slqty.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slprice.clearButtonMode = UITextFieldViewMode.WhileEditing
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
        
        let entityDescription = NSEntityDescription.entityForName("SList", inManagedObjectContext: moc)
        
        let item = SList(entity: entityDescription!, insertIntoManagedObjectContext: moc)
        
        item.slitem = slitem.text
        item.sldesc = sldesc.text
        item.slqty = slqty.text
        item.slprice = slprice.text
        item.slcross = false
        
        if slitem.text == nil{
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
        item?.slitem = slitem.text!
        item?.sldesc = sldesc.text!
        item?.slqty = slqty.text!
        item?.slprice = slprice.text!
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    
}

