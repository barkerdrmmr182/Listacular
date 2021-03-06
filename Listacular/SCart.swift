//
//  SCart.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class SCart: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCartCellDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    var selectedItem : List?
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        let primarySortDescription = NSSortDescriptor(key: "sccross", ascending: true)
        let secondarySortDescription = NSSortDescriptor(key: "sclist", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescription, secondarySortDescription]
        fetchRequest.predicate = NSPredicate(format:"sclist == true")
        return fetchRequest
        
    }
    
    func getFetchRequetController() ->NSFetchedResultsController{
        
        frc = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: "sccross", cacheName: nil)
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
        self.tableView.reloadData()
        
        //TableView Background Color
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorColor = UIColor.blackColor()
        self.tableView.rowHeight = 60
        tableView.reloadData()
        
        //"edit" bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SCart.editButtonPressed))
    }
    
    func editButtonPressed(){
        tableView.setEditing(!tableView.editing, animated: true)
        if tableView.editing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SCart.editButtonPressed))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SCart.editButtonPressed))
        }

    }
    
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
        let sectionHeader = "Items - #\(frc.sections![section].numberOfObjects)"
        let sectionHeader1 = "Crossed Off Items - #\(frc.sections![section].numberOfObjects)"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SCartCell
        
        //assign delegate
        cell.delegate = self
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.grayColor()
        cell.cellLabel.text = "\(items.scitem!) - Qty: \(items.scqty!)"
        cell.cellLabel.font = UIFont.systemFontOfSize(30)
        
        if (items.sccross == true) {
            cell.accessoryType = .Checkmark
            cell.cellLabel.textColor = UIColor.grayColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(25)
            self.tableView.rowHeight = 50
        } else {
            cell.accessoryType = .None
            cell.cellLabel.textColor = UIColor.blackColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(30)
            self.tableView.rowHeight = 60
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        
        if (items.sccross == true) {
            items.sccross = false
        } else {
            items.sccross = true
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    @IBAction func moveToPL(sender: AnyObject) {
        let sectionInfo = self.frc.sections![1]
        let objectsToAppend = sectionInfo.objects as! [List]
        for item in objectsToAppend {
            item.plist = true
            item.pcross = false
            item.sclist = false
            item.pitem = item.scitem
//            item.pqty = item.scqty
            item.pdesc = item.scdesc
//            item.pprice = item.scprice
            
        }
        self.performSegueWithIdentifier("moveToPL", sender: self)
        
        self.tableView.reloadData()
    }
    
    
    //delegate method
    
    func cellButtonTapped(cell: SCartCell) {
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        selectedItem = frc.objectAtIndexPath(indexPath) as? List
        
        self.performSegueWithIdentifier("editItem", sender: self)
    }
    
    //segue to add/edit
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editItem" {
            let SCListController:SCEdit = segue.destinationViewController as! SCEdit
            SCListController.item = selectedItem
        }
    }
    
}
