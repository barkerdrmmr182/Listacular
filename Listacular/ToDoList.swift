//
//  TDList.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class ToDoList: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, TDCellDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    var selectedItem : List?
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        let primarySortDescription = NSSortDescriptor(key: "tdcross", ascending: true)
        let secondarySortDescription = NSSortDescriptor(key: "tddate", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescription, secondarySortDescription]
        fetchRequest.predicate = NSPredicate(format:"tdlist == true")
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
    }
    @IBOutlet weak var deleteCompleted: UIButton!
    let eventStore = EKEventStore()
    
    override func viewWillAppear(animated: Bool) {
        checkCalendarAuthorizationStatus()
    }

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
        //SwipeGesture
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ToDoList.handleSwipes(_:)))
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ToDoList.handleSwipes(_:)))
        rightSwipe.direction = .Right
        leftSwipe.direction = .Left
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(leftSwipe)
        //EndSwipe
        
        //TableView Background Color
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor.blackColor()
        self.tableView.rowHeight = 60
        deleteCompleted.hidden = true
        self.tableView.allowsMultipleSelection = true
        tableView.reloadData()
        
        //"edit" bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ToDoList.editButtonPressed))
    }
    
    
    //Calendar Permissions
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized: break
            // Things are in line with being able to show the calendars in the table view
            
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            // We need to help them give us permission
            requestAccessToCalendar()
        }
    }
    
    func requestAccessToCalendar() {
        //alert for access denied
        let alert = UIAlertController(title: "Calendar Access Denied", message: "Please allow access to your calendar.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addAction(cancelAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Cancel) { (alertAction) in
            //Link to app settings
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(appSettings)
            }
        }
        
        alert.addAction(settingsAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        print("Access Denied")
    }

    
    func editButtonPressed(){
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ToDoList.editButtonPressed))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ToDoList.editButtonPressed))
        }
        
    }//end edit button
    
    override func viewDidDisappear(animated: Bool) {
        
        frc = getFetchRequetController()
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch _ {
            print("Failed to perform inital fetch.")
            return
        }
        self.tableView.reloadData()
    }
    
    // MARK: - TableView Data
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
    }
    
    //table section headers
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{

        if (frc.sections!.count > 0) {
            let sectionInfo = frc.sections![section]
            if (sectionInfo.name == "True") {
                return "Completed Tasks"
            } else {
                return sectionInfo.name
            }
        } else {
            return nil
        }
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
        let numberOfRowsInSection = frc.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TDCell
        
        //assign delegate
        cell.delegate = self
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.grayColor()
        cell.cellLabel.text = "\(items.tditem!) - \(items.tddate!)"
        cell.cellLabel.font = UIFont.systemFontOfSize(25)
        deleteCompleted.hidden = true
        
        if (items.tdcross! == true) {
            cell.accessoryType = .Checkmark
            cell.cellLabel.textColor = UIColor.grayColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(20)
            self.tableView.rowHeight = 50
            deleteCompleted.hidden = false
        } else {
            cell.accessoryType = .None
            cell.cellLabel.textColor = UIColor.blackColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(25)
            self.tableView.rowHeight = 60
            deleteCompleted.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        
        if (items.tdcross == true) {
            items.tdcross = false
        } else {
            items.tdcross = true
        }

        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //SwipeFunc
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            self.navigationController!.tabBarController!.selectedIndex = 0
        }
        if (sender.direction == .Right) {
            self.navigationController!.tabBarController!.selectedIndex = 2
        }

    }//EndSwipeFunc
    
    @IBAction func deleteTasks(sender: AnyObject) {
        let sectionInfo = self.frc.sections![self.frc.sections!.count - 1]
        
        let objectsToAppend = sectionInfo.objects as! [List]
        for item in objectsToAppend {
            if item.tdcross == true{
                self.moc.deleteObject(item)
                deleteCompleted.hidden = true
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    //delegate method
    func cellButtonTapped(cell: TDCell) {
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        selectedItem = frc.objectAtIndexPath(indexPath) as? List
        
        self.performSegueWithIdentifier("editItem", sender: self)
    }
    
    //segue to add/edit
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editItem" {
            let TDListController:TDEdit = segue.destinationViewController as! TDEdit
            TDListController.item = selectedItem
        }
    }
}