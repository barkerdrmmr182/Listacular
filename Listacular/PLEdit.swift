//
//  PLEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class PLEdit: UIViewController {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var pitem: UITextField!
    @IBOutlet weak var pdesc: UITextField!
    @IBOutlet weak var pqty: UITextField!
    @IBOutlet weak var pprice: UITextField!
    
    
    var item: List? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            pitem.text = item?.pitem
            pdesc.text = item?.pdesc
            pqty.text = item?.pqty
            pprice.text = item?.pprice
            
            
        }
        
        // "x" Delete Feature
        self.pitem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pdesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pqty.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pprice.clearButtonMode = UITextFieldViewMode.WhileEditing
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
        
        let entityDescripition = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
        
        let item = List(entity: entityDescripition!, insertIntoManagedObjectContext: moc)
        
        item.pitem = pitem.text
        item.pqty = pqty.text
        item.pdesc = pdesc.text
        item.pprice = pprice.text
        item.plist = true
        item.pcross = false
        
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
