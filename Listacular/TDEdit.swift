//
//  TDEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class TDEdit: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var tditem: UITextField!
    @IBOutlet weak var tddesc: UITextField!
    @IBOutlet weak var tdDone: UITextField!
    
    
    var item: List? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if item != nil{
            tditem.text = item?.tditem
            tddesc.text = item?.tddesc
            tdDone.text = item?.tdtime
            
        }
        
        // "x" Delete Feature
        self.tditem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.tddesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        

    }

    @IBAction func tdDoneAction(sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        tdDone.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
    }
  

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func dismissVC() {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
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
        
        item.tditem = tditem.text
        item.tddesc = tddesc.text
        item.tdtime = tdDone.text

        item.tdcross = false
        item.tdlist = true
        
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
        item?.tdtime = tdDone.text!
        
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        dateFormatter.dateFormat = "EE., MMMM dd, yyyy hh:mm a"
        
        if tdDone.text == nil {
        tdDone.text = dateFormatter.stringFromDate(sender.date)
        }
        if tdDone.text != nil {
        tdDone.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
}
