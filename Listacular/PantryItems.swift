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
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    @IBOutlet weak var pitem: UILabel!
    @IBOutlet weak var pdesc: UILabel!
    @IBOutlet weak var pqty: UILabel!
    @IBOutlet weak var pprice: UILabel!
    
    @IBOutlet weak var minStepperLabel: UILabel!
    @IBOutlet weak var minStepper: UIStepper!
    @IBAction func minStepperChanged(sender: UIStepper) {
        minStepperLabel.text = Int(sender.value).description
    }
    
    @IBOutlet weak var qtyStepperLabel: UILabel!
    @IBOutlet weak var qtyStepper: UIStepper!
    @IBAction func qtyStepperChanged(sender: UIStepper) {
        qtyStepperLabel.text = Int(sender.value).description
    }
    
    var item: List? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            
            pitem.text = item?.pitem
            pdesc.text = item?.pdesc
            pqty.text = item?.pqty
            pprice.text = item?.pprice
            qtyStepperLabel.text = item?.pqty
            minStepperLabel.text = item?.pminstepperlabel
            
        }
        let myDouble = Double(pqty.text!)
        qtyStepper.value = myDouble!
        qtyStepper.minimumValue = 0
        qtyStepper.wraps = false
        qtyStepper.autorepeat = true
        qtyStepper.maximumValue = 100
        
        if minStepperLabel.text == nil {
            minStepper.value = 1
            let myDouble2 = minStepper.value
            let myDoubleString = String(myDouble2)
            minStepperLabel.text = myDoubleString
        }else{
        let myDouble1 = Double(minStepperLabel.text!)
        minStepper.value = myDouble1!
        minStepper.minimumValue = 1
        minStepper.wraps = false
        minStepper.autorepeat = true
        minStepper.maximumValue = 100
    }
        
        if qtyStepper.value <= minStepper.value {
            
            invAlert1()
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func dismissVC() {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    var setAction:UIAlertAction?

    @IBAction func saveButton(sender: AnyObject) {
        invAlert2()
    }
    //alertController 
    func invAlert1() {
        if qtyStepper.value <= minStepper.value{
            
            let alertController = UIAlertController(title: "Minimum Inventory Alert!", message:
                "Your inventory of \(pitem.text!) is low. How many would you like to add to your shopping list?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler { [unowned self] (textField: UITextField!) -> Void in
                textField.placeholder = "Quantity desired."
                textField.keyboardType = .NumbersAndPunctuation
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { [unowned self] (notification) in
                    let textField = notification.object as! UITextField
                    
                    self.setAction!.enabled = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty == false
                }
            }
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:nil))
            setAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default, handler: {[unowned self](action) -> Void in
                
                let textField = alertController.textFields!.first as UITextField?
                if (self.item?.slqty == nil){
                    self.item?.slqty = textField?.text
                }else{
                    var total = 0
                    let oldQty = Int((self.item?.slqty!)!)
                    let addQty = Int((textField?.text)!)
                    total = (oldQty! + addQty!)
                    self.item?.slqty = String(total)
                }

                
                
                self.moveToSL(self)
                
                
                self.saveToCoreDate()})
            setAction?.enabled = false // initialy disabled
            
            alertController.addAction(setAction!)
            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            if item != nil {
                edititems()
            } else {
                createNewitem()
            }
            
            
            dismissVC()
        }
    }

    func invAlert2() {
        if qtyStepper.value <= minStepper.value{
            
            let alertController = UIAlertController(title: "Minimum Inventory Alert!", message:
                "Your inventory of \(pitem.text!) is low. How many would you like to add to your shopping list?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler { [unowned self] (textField: UITextField!) -> Void in
                textField.placeholder = "Quantity desired."
                textField.keyboardType = .NumbersAndPunctuation
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { [unowned self] (notification) in
                    let textField = notification.object as! UITextField
                    
                    self.setAction!.enabled = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty == false
                }
            }
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:{[unowned self] _ in self.saveToCoreDate()}))
            setAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default, handler: {[unowned self](action) -> Void in
                
                let textField = alertController.textFields!.first as UITextField?
                if (self.item?.slqty == nil){
                self.item?.slqty = textField?.text
                }else{
                    var total = 0
                    let oldQty = Int((self.item?.slqty!)!)
                    let addQty = Int((textField?.text)!)
                    total = (oldQty! + addQty!)
                    self.item?.slqty = String(total)
                }
                self.moveToSL(self)
                
                
                self.saveToCoreDate()})
            setAction?.enabled = false // initialy disabled
            
            alertController.addAction(setAction!)
            self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            if item != nil {
                edititems()
            } else {
                createNewitem()
            }
            
            
            dismissVC()
        }
    }//alertController end
    
    func saveToCoreDate() {
        // save if item is not nil
        if item != nil {
            edititems()
            do {
                try moc.save()
            } catch let error {
                print(error)
            }
        }else{
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
        item.pqtystepperlabel = pqty.text
        item.pminstepperlabel = minStepperLabel.text
        item.pminsteppervalue = minStepper.value
        
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
        item?.pqtystepperlabel = pqty.text!
        item?.pminstepperlabel = minStepperLabel.text!
        item?.pminsteppervalue = minStepper.value
        
        do {
            try moc.save()
        } catch {
            return
        }
}
    
    func moveToSL(sender: AnyObject) {
        
            item!.slist = true
            item!.plist = true
            item!.slcross = false
            item!.slitem = item!.pitem
            item!.sldesc = item!.pdesc
            item!.slprice = item!.pprice
            item!.slsuffix = item!.psuffix
            item!.slcategory = item!.pcategory
            item!.pqty = pqty.text!
        //updating slminqty when adding to shoppinglist through alert.
        let myDouble4 = minStepper.value
        let myDoubleString = String(myDouble4)
        item!.slminqty = myDoubleString
    }
    
        func createNewitem() {
            // just creating an empty item and give the job to filling it to editItem method.
            let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
            
            // assign the empty item to self.item.
            let item = List(entity: entityDescription!, insertIntoManagedObjectContext: moc)
            
            // from my understanding to your code the values below belongs to the new item only. please change it if needed.
            item.plist = true
            item.pcross = false
            // assign the new item to self.item
            self.item = item
            
        }
}