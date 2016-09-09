//
//  MealRecipe.swift
//  Listacular
//
//  Created by Will Zimmer on 2/2/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData
import EventKit


class MealRecipe: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    var selectedItem : List?
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        fetchRequest.predicate = NSPredicate(format:"mplist == true")
        return fetchRequest
    }
    
    func getFetchRequetController() ->NSFetchedResultsController{
        
        frc = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        return frc
    }
    @IBOutlet weak var Recipe: UITextField!
    @IBOutlet weak var mealOfDay: UITextField!
    @IBOutlet weak var recipeItem: UITextField!
    @IBOutlet weak var dayOfWeek: UITextField!
   
    @IBOutlet weak var rqty: UITextField!
    
    
    var savedEventId: String = ""
    var item: List? = nil
    
    var mealDayPicker = ["Breakfast","Lunch","Dinner","Snacks"]
    
    var RecipeObserver: NSObjectProtocol!
    var mealObserver: NSObjectProtocol!
    var recipeItemObserver: NSObjectProtocol!
    var directionObserver: NSObjectProtocol!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //mealPicker delegate
        let mealDaypicker = UIPickerView()
        mealDaypicker.delegate = self
        mealOfDay.inputView = mealDaypicker
        mealOfDay.delegate = self
        dayOfWeek.delegate = self
        
        
        // item not nill means we're editing.
        if item != nil{
            updateUIFromItem()
        }
        
        self.Recipe.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.mealOfDay.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.recipeItem.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        RecipeObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.Recipe, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        mealObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.mealOfDay, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        recipeItemObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.recipeItem, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
               
        // validate the form and apply it to save butotn.
        btnSave.enabled = formIsValid
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(RecipeObserver)
        NSNotificationCenter.defaultCenter().removeObserver(mealObserver)
        NSNotificationCenter.defaultCenter().removeObserver(recipeItemObserver)
    }

    //Dismiss Keyboard when touched outside of textFields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func updateUIFromItem() {
        if let item = self.item {
            Recipe.text = item.mpitem
            mealOfDay.text = item.mpcategory
            recipeItem.text = item.ringredients
            dayOfWeek.text = item.mpdate
            rqty.text = item.rqty0
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
        guard formIsValid else {
            print("form is not valid")
            return
        }
        // create newItem if it's nil
        if item == nil {
            createNewitem()
            
        }
        // update the item
        updateItem()
        checkCalendarAuthorizationStatus()
        
    }
    
    //Calendar Permissions
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            // Things are in line with being able to show the calendars in the table view
            saveToCoreDate()
            addToCalendar()
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            // We need to help them give us permission
            requestAccessToCalendar()
        }
    }
    
    func requestAccessToCalendar() {
        //alert for access denied
        let alert = UIAlertController(title: "Calendar Access Denied", message: "Please allow access to your calendar.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (alertAction) in
            if self.item == nil {
                self.createNewitem()
                
            }else{
            // update the item
            self.updateItem()
            }
            self.dismissVC()
        }

        
        let settingsAction = UIAlertAction(title: "Settings", style: .Cancel) { (alertAction) in
            //Link to app settings
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        print("Access Denied")
    }

    
    //add Meal to Calendar
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.notes = "\(self.Recipe.text!) - See Meal Planning on Listacular"
        
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            savedEventId = event.eventIdentifier
            
        } catch {
            
            print("Access Denied")
        }
    }
    
    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.eventWithIdentifier(eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
            } catch {
                print("Deleted")
            }
        }
    }
    
    func addToCalendar(){
        let eventStore = EKEventStore()
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "US_en")
        formatter.dateFormat = "EE., MMMM dd, yyyy h:mm a"
        let date = formatter.dateFromString(dayOfWeek.text!)
        
        
        let startDate = date
        let endDate = startDate!.dateByAddingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.createEvent(eventStore, title: "\(self.mealOfDay.text!)", startDate: startDate!, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: "\(self.mealOfDay.text!)", startDate: startDate!, endDate: endDate)
        }
        
    }//end Calendars
    
    func itemFetchRequest1() -> NSFetchRequest{
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let pItemFetch = NSFetchRequest(entityName: "List")
        let sortDescription = NSSortDescriptor(key: "pitem", ascending: true)
        pItemFetch.sortDescriptors = [sortDescription]
        pItemFetch.predicate = NSPredicate(format:"pitem == %@", item!.ringredients!)
        
        do {
            try moc.executeFetchRequest(pItemFetch) 
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        return pItemFetch
        
    }

    
    func createNewitem() {
        guard self.item == nil else {
            print("trying to create a new item while there is already one.")
            return
        }
        let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
        
        // assign the empty item to self.item.
        let item = List(entity: entityDescription!, insertIntoManagedObjectContext: moc)
        
        
        item.mplist = true
        item.mpcross = false
        // assign the new item to self.item
        self.item = item
        
        item.mpitem = Recipe.text
        item.mpcategory = mealOfDay.text
        item.ringredients = recipeItem.text
        item.mpdate = dayOfWeek.text
        item.rqty0 = rqty.text
        
        itemFetchRequest1()
        
        let fetch = itemFetchRequest1()
        let plistItems = try! moc.executeFetchRequest(fetch)
        let plistItem = plistItems[0] as! List

            //get value of string
            let stringNumber0 = item.rqty0
            let stringNumber1 = plistItem.pqty
            //convert string to Int
            let numberFromString0 = Int(stringNumber0!)
            let numberFromString1 = Int(stringNumber1!)
            //get sum of Int
            let sum = (numberFromString1)! - (numberFromString0)!
            let myInt:Int = sum
            //convert back Int back to string
            let myString:String = String(myInt)
            //delclare string as qty.
            plistItem.pqty = myString
        
    }
    var formIsValid:Bool {
        // make sure all is not null.
        //TODO: 
        return Recipe.text?.isEmpty  == false
            && mealOfDay.text?.isEmpty  == false
            && dayOfWeek.text?.isEmpty   == false
            && recipeItem.text?.isEmpty == false
    }
    func updateItem() {
        
        // making sure item is not nil.
        if item == nil {
            createNewitem()
        }
        
        if formIsValid {
            
            // update the item with what in the text fields.
            item!.mpitem = Recipe.text
            item!.mpcategory = mealOfDay.text
            item!.ringredients = recipeItem.text
            item!.mpdate = dayOfWeek.text
            item!.rqty0 = rqty.text
            
        } else {
            print("Form is not valid")
        }
        
    }

    /**
     Saves the item object to core data.
     */
    func saveToCoreDate() {
        // save if item is not nil
        if item != nil {
            do {
                try moc.save()
            } catch let error {
                print(error)
            }
        }
        dismissVC()
    }
    
    func createitems() {
        
        let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
        
        let item = List(entity: entityDescription!, insertIntoManagedObjectContext: moc)
        
        item.mpitem = Recipe.text
        item.mpcategory = mealOfDay.text
        item.ringredients = recipeItem.text
        item.mpdate = dayOfWeek.text
        item.rqty0 = rqty.text
        item.mplist = true
        item.mpcross = false
        
        do {
            try moc.save()
        } catch _ {
            return
        }
    }

    func edititems() {
        item?.mpitem = Recipe.text!
        item?.mpcategory = mealOfDay.text!
        item?.ringredients = recipeItem.text!
        item?.mpdate = dayOfWeek.text!
        item?.rqty0 = rqty.text!
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    @IBAction func dayOfWeek(sender: AnyObject) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        dateFormatter.dateFormat = "EE., MMM dd, yyyy h:mm a"
        datePickerView.minimumDate = NSDate()
        dayOfWeek.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(MealRecipe.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }

    
    
    func handleDatePicker(sender: UIDatePicker) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        let dateFormatter = NSDateFormatter()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        dateFormatter.dateFormat = "EE., MMM dd, yyyy h:mm a"
        
        if dayOfWeek.text == nil {
            dayOfWeek.text = dateFormatter.stringFromDate(sender.date)
        }
        if dayOfWeek.text != nil {
            dayOfWeek.text = dateFormatter.stringFromDate(sender.date)
        }
    }
   
    //set up pickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
        }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealDayPicker.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealDayPicker[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        mealOfDay.text = mealDayPicker[row]
        print(mealOfDay.text!)
    }//end pickerView
    
}