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

class MealRecipe: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var Recipe: UITextField!
    @IBOutlet weak var meal: UITextField!
    @IBOutlet weak var recipeItem: UITextField!
    @IBOutlet weak var direction: UITextView!
    
    var item: List? = nil
    
    
    
    var dayOfWeek = String()
    var mealOfDay = String()
    
    var mealDayPicker = [["Monday", "Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"], ["Breakfast","Lunch","Dinner","Snacks"]]
    
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
        meal.inputView = mealDaypicker
        //mealPicker Default Row
        mealDaypicker.selectRow(1, inComponent: 0, animated: true)
        mealDaypicker.selectRow(1, inComponent: 1, animated: true)
        
        
        // item not nill means we're editing.
        if item != nil{
            updateUIFromItem()
        }
        
        
        self.Recipe.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.meal.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.recipeItem.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        
        RecipeObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.Recipe, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        mealObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.meal, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
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
            meal.text = item.mpcategory
            recipeItem.text = item.ringredients
            direction.text = item.rdirections
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
        addToCalendar()
        saveToCoreDate()
    }
    
    //add Meal to Calendar
    func addToCalendar(){
        if item!.mpcalendar == true {
        let eventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType( EKEntityType.Event, completion:{(granted, error) in
            let calendars = eventStore.calendarsForEntityType(.Event)
            
            for calendar in calendars {
            if calendar.title == "Calendar" {
                
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event = EKEvent(eventStore: eventStore)
                
                event.title = "\(self.dayOfWeek, self.mealOfDay)"
                event.startDate = NSDate()
                event.endDate = NSDate()
                event.allDay = true
                event.notes = "See Meal Planning on Listacular"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                var event_id = "\((self.dayOfWeek, self.mealOfDay))"
                do{
                    try eventStore.saveEvent(event, span: .ThisEvent)
                    event_id = event.eventIdentifier
                }
                catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
                
                if(event_id != ""){
                    print("event added !")    
                }
                }
                }
            }
        })}else{
            return
        }
        }
    
    func createNewitem() {
        guard self.item == nil else {
            print("trying to create a new item while there is already one.")
            return
        }
        // just creating an empty item and let give the job to filling it to editItem method.
        let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
        
        // assign the empty item to self.item.
        let item = List(entity: entityDescription!, insertIntoManagedObjectContext: moc)
        
        // from my understanding to your code the values below belongs to the new item only. please change it if needed.
        item.mplist = true
        item.mpcross = false
        // assign the new item to self.item
        self.item = item
        
    }
    var formIsValid:Bool {
        // make sure all is not null.
        //TODO: you may check for the number values is only numbers too.
        return Recipe.text?.isEmpty  == false
            && meal.text?.isEmpty  == false
//            && direction.text?.isEmpty   == false
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
            item!.mpcategory = meal.text
            item!.ringredients = recipeItem.text
            item!.rdirections = direction.text
            
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
        item.mpcategory = meal.text
        item.ringredients = recipeItem.text
        item.rdirections = direction.text
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
        item?.mpcategory = meal.text!
        item?.ringredients = recipeItem.text!
        item?.rdirections = direction.text!
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
   
    //set up pickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return mealDayPicker.count
        }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealDayPicker[component].count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealDayPicker[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        switch (component){
        case 0:
            dayOfWeek = mealDayPicker[component][row]
        case 1:
            mealOfDay = mealDayPicker[component][row]
        default:break
        }
       meal.text = "\((dayOfWeek, mealOfDay))"
    print(meal!)
    }//end pickerView

}
