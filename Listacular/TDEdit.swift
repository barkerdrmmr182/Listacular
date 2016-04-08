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
    @IBOutlet weak var tdtime: UITextField!
    
    
    var item: List? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if item != nil{
            tditem.text = item?.tditem
            tddesc.text = item?.tddesc
            tdDone.text = item?.tddate
            tdtime.text = item?.tdtime
            
        }
        
        // "x" Delete Feature
        self.tditem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.tddesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        

    }

    @IBAction func tdDoneAction(sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.minimumDate = NSDate()
        tdDone.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(TDEdit.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
  
    @IBAction func tdtimeAction(sender: AnyObject) {
        let timePickerView  : UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = UIDatePickerMode.Time
        timePickerView.minimumDate = NSDate()
        tdtime.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(TDEdit.handleTimePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        item.tddate = tdDone.text
        item.tdtime = tditem.text

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
        item?.tddate = tdDone.text!
        item?.tdtime = tdtime.text!
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        dateFormatter.dateFormat = "EE., MMMM dd, yyyy"
        
        if tdDone.text == nil {
        tdDone.text = dateFormatter.stringFromDate(sender.date)
        }
        if tdDone.text != nil {
        tdDone.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        let timePickerView  : UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        timePickerView.datePickerMode = UIDatePickerMode.Time
        dateFormatter.dateFormat = "hh:mm a"
        
        if tdtime.text == nil {
            tdtime.text = dateFormatter.stringFromDate(sender.date)
        }
        if tdtime.text != nil {
            tdtime.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
}
