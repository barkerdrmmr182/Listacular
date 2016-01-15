//
//  SCEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class SCEdit: UIViewController {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var scitem: UITextField!
    @IBOutlet weak var scdesc: UITextField!
    @IBOutlet weak var scqty: UITextField!
    @IBOutlet weak var scprice: UITextField!
    
    
    var item: SCList? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            scitem.text = item?.scitem
            scdesc.text = item?.scdesc
            scqty.text = item?.scqty
            scprice.text = item?.scprice
        }
        
        // "x" Delete Feature
        self.scitem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.scdesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.scqty.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.scprice.clearButtonMode = UITextFieldViewMode.WhileEditing
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
        
        let entityDescription = NSEntityDescription.entityForName("SCList", inManagedObjectContext: moc)
        
        let item = SCList(entity: entityDescription!, insertIntoManagedObjectContext: moc)
        
        item.scitem = scitem.text
        item.scdesc = scdesc.text
        item.scqty = scqty.text
        item.scprice = scprice.text
        item.sccross = false
        
        if scitem.text == nil{
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
        item?.scitem = scitem.text!
        item?.scdesc = scdesc.text!
        item?.scqty = scqty.text!
        item?.scprice = scprice.text!
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
}

