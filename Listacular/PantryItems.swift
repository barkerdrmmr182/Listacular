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
    
    
    var item: PList? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            pitem.text = item?.pitem
            pdesc.text = item?.pdesc
            pqty.text = item?.pqty
            pprice.text = item?.pprice
            qtyStepperLabel.text = item?.pqty
            minStepperLabel.text = item?.minstepperlabel
            
            
            
            
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
            if qtyStepper.value <= minStepper.value{
                let alertController = UIAlertController(title: "Minimum Inventory Alert", message:
                    "Your inventory of \(pitem.text!) is low.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Add to Shopping List", style: UIAlertActionStyle.Default,handler: nil))
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) in
                    self.dismissVC()}))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }

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
        item.qtystepperlabel = pqty.text
        item.minstepperlabel = minStepperLabel.text
        item.minsteppervalue = minStepper.value
        
        
        
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
        item?.qtystepperlabel = pqty.text!
        item?.minstepperlabel = minStepperLabel.text!
        item?.minsteppervalue = minStepper.value
        
        
        
        do {
            try moc.save()
        } catch {
            return
        }
}
}