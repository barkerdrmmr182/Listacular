//
//  MealPlanning.swift
//  Listacular
//
//  Created by Will Zimmer on 2/1/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData
import EventKit


class MealPlanning: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, MealTableCellDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    var selectedItem : List?
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        let primarySortDescription = NSSortDescriptor(key: "mpcross", ascending: true)
        let secondarySortDescription = NSSortDescriptor(key: "mpcategory", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescription, secondarySortDescription]
        fetchRequest.predicate = NSPredicate(format:"mplist == true")
        return fetchRequest
    }
    
    func getFetchRequetController() ->NSFetchedResultsController{
        
        frc = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        return frc
    }


    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func AddNew(sender: AnyObject) {
        
        frc = getFetchRequetController()
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        self.tableView.reloadData()
    }//End AddNew

    
//    var titles : [String] = []
//    var startDates : [NSDate] = []
//    var endDates : [NSDate] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        frc = getFetchRequetController()
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        
        //Swipe Between Tabs
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe.direction = .Right
        leftSwipe.direction = .Left
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
        //end Swipe
        
        //TableView Background Color
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor.blackColor()
        self.tableView.rowHeight = 60
        tableView.reloadData()
        
        //"edit" bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        
        //MARK: Get Permission From Calendar
//        let eventStore = EKEventStore()
//        
//        
//        switch EKEventStore.authorizationStatusForEntityType(.Event) {
//        case .Authorized:
//            readEvents()
//        case .Denied:
//            print("Access denied")
//        case .NotDetermined:
//            
//            eventStore.requestAccessToEntityType(.Event, completion: { (granted: Bool, NSError) -> Void in
//                if granted {
//                    self.readEvents()
//                    
//                }else{
//                    print("Access denied")
//                }
//                
//                
//                
//            })
//        default:
//            print("Case Default")
//        }
//        self.tableView.reloadData()
//    }
    
    
    //Get Meals Events From Calendar
//    func readEvents() {
//        
//        let eventStore = EKEventStore()
//        let calendars = eventStore.calendarsForEntityType(.Event)
//        
//        for calendar in calendars {
//            if calendar.title == "Meal Planning" {
//                
//                let oneWeekAgo = NSDate(timeIntervalSinceNow: -7*24*3600)
//                let oneWeekAfter = NSDate(timeIntervalSinceNow: +7*24*3600)
//                
//                let predicate = eventStore.predicateForEventsWithStartDate(oneWeekAgo, endDate: oneWeekAfter, calendars: [calendar])
//                
//                let events = eventStore.eventsMatchingPredicate(predicate)
//                
//                for event in events {
//                    
//                    titles.append(event.title)
//                    startDates.append(event.startDate)
//                    endDates.append(event.endDate)
//                }
//            }
//        }//End Meals From Calendar
    }//End ViewDidLoad
    
    func editButtonPressed(){
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }
        
    }//end edit button
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // fetch before view appears. to reftech when coming back for add/edit.
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject:NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        moc.deleteObject(managedObject)
        do {
            try moc.save()
        } catch _ {
            print("Failed to save.")
            return
        }
    }
    
    //number of Sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
    }
    
    //Table Section Headers
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if (frc.sections!.count > 0) {
            let sectionInfo = frc.sections![section]
            if (sectionInfo.name == "True") {
                return "Items in Cart - #\(sectionInfo.numberOfObjects)"
            } else {
                return sectionInfo.name
            }
        } else {
            return nil
        }
    }
    //Header height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40
    }
    //Header Background/Text Color
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //header background color
        view.tintColor = UIColor.lightGrayColor()
        
        //header text color
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.blueColor()
        
    }
    //number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = frc.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    //Segue when Row Selected.
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        self.performSegueWithIdentifier("mealRecipe", sender: self)
//        
//    }
    //Configure Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MealPlanningCell
        
        //assign delegate
        cell.delegate = self
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.grayColor()
        cell.cellLabel?.text = "\(items.mpitem!)"
        cell.backgroundColor = UIColor.clearColor()
        cell.cellLabel.font = UIFont.systemFontOfSize(25)
        
        
        
        return cell
}
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    //Swipes
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            self.navigationController!.tabBarController!.selectedIndex = 3
        }
        if (sender.direction == .Right) {
            self.navigationController!.tabBarController!.selectedIndex = 1
        }
    }
    
    ///delegate method
    func cellButtonTapped(cell: MealPlanningCell) {
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        selectedItem = frc.objectAtIndexPath(indexPath) as? List
        self.performSegueWithIdentifier("mealRecipe", sender: self)
    }
    
    //segue to add/edit
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "mealRecipe" {
            let MListController:MealRecipe = segue.destinationViewController as! MealRecipe
            MListController.item = selectedItem
        }
    }}