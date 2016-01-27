//
//  PantryList.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class PantryList: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, PantryCellDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    var selectedItem : List?
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        let primarySortDescription = NSSortDescriptor(key: "pcross", ascending: true)
        let secondarySortDescription = NSSortDescriptor(key: "pitem", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescription, secondarySortDescription]
        fetchRequest.predicate = NSPredicate(format:"plist == true")
        return fetchRequest
    }
    
    func getFetchRequetController() ->NSFetchedResultsController{
        
        frc = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: "pcross", cacheName: nil)
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
        moveToSL.hidden = true
        tableView.reloadData()
        
        //"edit" bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
    }
    //"edit" button code
    func editButtonPressed(){
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
        }
        
    }//end "edit" button
    
    
    
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
    
    //TableView Data
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
        let sectionHeader = "Pantry Inventory - #\(frc.sections![section].numberOfObjects)"
        let sectionHeader1 = "Inevtory Needed - #\(frc.sections![section].numberOfObjects)"
        if (frc.sections!.count > 0) {
            let sectionInfo = frc.sections![section]
            if (sectionInfo.name == "0") { // "0" is the string equivalent of false
                return sectionHeader
            } else {
                return sectionHeader1
            }
        } else {
            return nil;
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PantryCell
        
        //assign delegate
        cell.delegate = self
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.grayColor()
        cell.cellLabel.text = "\(items.pitem!) - Qty: \(items.pqty!)"
        cell.cellLabel.font = UIFont.systemFontOfSize(25)
        moveToSL.hidden = true
        
        if (items.pcross == true) {
            cell.accessoryType = .Checkmark
            cell.cellLabel.textColor = UIColor.grayColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(20)
            self.tableView.rowHeight = 50
            moveToSL.hidden = false
        } else {
            cell.accessoryType = .None
            cell.cellLabel.textColor = UIColor.blackColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(25)
            self.tableView.rowHeight = 60
            moveToSL.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        
        if (items.pcross == true) {
            items.pcross = false
        } else {
            items.pcross = true
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
    @IBOutlet weak var moveToSL: UIButton!
    @IBAction func moveToSL(sender: AnyObject) {
        let sectionInfo = self.frc.sections![1]
        let objectsToAppend = sectionInfo.objects as! [List]
        for item in objectsToAppend {
            item.slist = true
            item.slcross = false
            item.plist = false
            item.slitem = item.pitem
            item.slqty = item.pqty
            item.sldesc = item.pdesc
            item.slprice = item.pprice
            
            
        }
//        self.performSegueWithIdentifier("moveToSL", sender: self)
    }
    
    //SwipeFunc
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Right) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ShoppingList")
            let navigationController = UINavigationController(rootViewController: vc)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
        if (sender.direction == .Left) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ToDoList")
            let navigationController = UINavigationController(rootViewController: vc)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }//EndSwipeFunc
    
    func cellButtonTapped(cell: PantryCell) {
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        selectedItem = frc.objectAtIndexPath(indexPath) as? List
        
        self.performSegueWithIdentifier("editItem", sender: self)
    }
    
    //segue to add/edit
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editItem" {
            let PListController:PantryItems = segue.destinationViewController as! PantryItems
            PListController.item = selectedItem
        }
    }

}

