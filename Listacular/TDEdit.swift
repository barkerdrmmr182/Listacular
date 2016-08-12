//
//  TDEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class TDEdit: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var tditem: UITextField!
    @IBOutlet weak var tddesc: UITextField!
    @IBOutlet weak var tdDone: UITextField!
    
    
    var savedEventId: String = ""
    var item: List? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if item != nil{
            tditem.text = item?.tditem
            tddesc.text = item?.tddesc
            tdDone.text = item?.tddate
            
            
        }
        
        // "x" Delete Feature
        self.tditem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.tddesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        

    }

    @IBAction func tdDoneAction(sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        dateFormatter.dateFormat = "EE., MMM dd, yyyy h:mm a"
        datePickerView.minimumDate = NSDate()
        tdDone.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(TDEdit.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
        
        addToCalendar()
        dismissVC()
    }
    
    func createitems() {
        
        let entityDescripition = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
        
        let item = List(entity: entityDescripition!, insertIntoManagedObjectContext: moc)
        
        item.tditem = tditem.text
        item.tddesc = tddesc.text
        item.tddate = tdDone.text
        

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
        dateFormatter.dateFormat = "EE., MMM dd, yyyy h:mm a"
        
        if tdDone.text == nil {
        tdDone.text = dateFormatter.stringFromDate(sender.date)
        }
        if tdDone.text != nil {
        tdDone.text = dateFormatter.stringFromDate(sender.date)
        }
    }
    
       
    //add To Do to Calendar
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.notes = "\(self.tditem.text!) - See To Do List on Listacular"
        
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            savedEventId = event.eventIdentifier
        } catch {
//            let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
//            UIApplication.sharedApplication().openURL(openSettingsUrl!)
            
            print("Access Denied")
        }
    }
    
    func addToCalendar(){
        let eventStore = EKEventStore()
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "US_en")
        formatter.dateFormat = "EE., MMMM dd, yyyy h:mm a"
        let date = formatter.dateFromString(tdDone.text!)
        
        let startDate = date
        let endDate = startDate!.dateByAddingTimeInterval(60 * 60)
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.createEvent(eventStore, title: "\(self.tditem.text!)", startDate: startDate!, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: "\(self.tditem.text!)", startDate: startDate!, endDate: endDate)
        }
    }

    
}
