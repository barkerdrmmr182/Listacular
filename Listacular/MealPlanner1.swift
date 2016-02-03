//
//  MealPlanner1.swift
//  Listacular
//
//  Created by Will Zimmer on 2/1/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit
import EventKit


class MealPlanner1: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var titles : [String] = []
    var startDates : [NSDate] = []
    var endDates : [NSDate] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get Meals From Calendar
        let eventStore = EKEventStore()
        
        
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
        case .Authorized:
            readEvents()
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            
            eventStore.requestAccessToEntityType(.Event, completion: { (granted: Bool, NSError) -> Void in
                if granted {
                    self.readEvents()
                    
                }else{
                    print("Access denied")
                }
                
                
                
            })
        default:
            print("Case Default")
        }
        self.tableView.reloadData()
    }
    
    
    
    func readEvents() {
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendarsForEntityType(.Event)
        
        for calendar in calendars {
            if calendar.title == "Meal Planning" {
                
                let oneWeekAgo = NSDate(timeIntervalSinceNow: -7*24*3600)
                let oneWeekAfter = NSDate(timeIntervalSinceNow: +7*24*3600)
                
                let predicate = eventStore.predicateForEventsWithStartDate(oneWeekAgo, endDate: oneWeekAfter, calendars: [calendar])
                
                let events = eventStore.eventsMatchingPredicate(predicate)
                
                for event in events {
                    
                    titles.append(event.title)
                    startDates.append(event.startDate)
                    endDates.append(event.endDate)
                }
            }
        }//End Meals From Calendar
        
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
    }//End ViewDidLoad
    
    func editButtonPressed(){
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }
        
    }//end edit button
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        let pastMeals = "Meals"
        
        return pastMeals
    }
    
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    //Segue when Row Selected.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("mealRecipe", sender: self)
        
    }
    //Configure Cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        
        cell.textLabel?.text = "\(titles[indexPath.row]) - \(startDates[indexPath.row])"
        cell.backgroundColor = UIColor.clearColor()
        print(cell.textLabel?.text)
        
        return cell
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
    
    /*segue to add/edit
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "mealRecipe" {
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let MPListController:MealRecipe = segue.destinationViewController as! MealRecipe
            let items:List = frc.objectAtIndexPath(indexPath!) as! List
            MPListController.item = items
        }
    }*/
}