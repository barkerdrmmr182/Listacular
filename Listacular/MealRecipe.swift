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
    @IBOutlet weak var meal: UITextField!
    @IBOutlet weak var recipeItem: UITextField!
    @IBOutlet weak var direction: UITextView!
    @IBAction func addBtn(sender: AnyObject) {
//        add()
    }
    
    var item: List? = nil
    
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
        mealDaypicker.selectRow(0, inComponent: 0, animated: true)
        mealDaypicker.selectRow(0, inComponent: 1, animated: true)
        meal.delegate = self
        
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
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccessToEntityType( EKEntityType.Event, completion:{(granted, error) in
            let calendars = eventStore.calendarsForEntityType(.Event)
            
            for calendar in calendars {
            if calendar.title == "Calendar" {
                
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(error)")
                
                let event = EKEvent(eventStore: eventStore)
                
                event.title = "\(self.meal.text!)"
                event.startDate = NSDate()
                event.endDate = NSDate()
                event.allDay = true
                event.notes = "\(self.Recipe.text!) - See Meal Planning on Listacular"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                var event_id = "\(self.meal.text!)"
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
        })
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
            && direction.text?.isEmpty   == false
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
    /*add Btn
    func add() {
            let alertController = UIAlertController(title: "Add Ingredients", message:
                "Add Ingredients", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addTextFieldWithConfigurationHandler { [unowned self] (textField: UITextField!) -> Void in
                textField.placeholder = "Ingredients."
                textField.keyboardType = .Default
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { [unowned self] (notification) in
                    let textField = notification.object as! UITextField
                    
                    self.setAction!.enabled = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty == false
                }
            }
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:{[unowned self] _ in self.saveToCoreDate()}))
            setAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {[unowned self](action) -> Void in
                
                let textField = alertController.textFields!.first as UITextField?
                self.ringredients.append((textField?.text)!)
                
               self.updateItem() })
            setAction?.enabled = false // initialy disabled
            
            alertController.addAction(setAction!)
            self.presentViewController(alertController, animated: true, completion: nil)
    } //end add*/
    
   
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
        let dayOfWeek = mealDayPicker[0][pickerView.selectedRowInComponent(0)]
        let mealOfDay = mealDayPicker[1][pickerView.selectedRowInComponent(1)]
        meal.text = dayOfWeek + " " + mealOfDay
    print(meal.text!)
    }//end pickerView

}
