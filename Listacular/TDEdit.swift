//
//  TDEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class TDEdit: UIViewController {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var tditem: UITextField!
    @IBOutlet weak var tddesc: UITextField!
    
    
    
    var item: TDList? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            tditem.text = item?.tditem
            tddesc.text = item?.tddesc
            
            
            
        }
        
        // "x" Delete Feature
        self.tditem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.tddesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        
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
        
        let entityDescripition = NSEntityDescription.entityForName("TDList", inManagedObjectContext: moc)
        
        let item = TDList(entity: entityDescripition!, insertIntoManagedObjectContext: moc)
        
        item.tditem = tditem.text
        item.tddesc = tddesc.text
        
        if tditem.text == nil{
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
        item?.tditem = tditem.text!
        item?.tddesc = tddesc.text!
        
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    
    
}
