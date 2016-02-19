//
//  ShoppingList.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class ShoppingList: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SLTableCellDelegate {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var frc : NSFetchedResultsController = NSFetchedResultsController()
    
    var selectedItem : List?
    
    func itemFetchRequest() -> NSFetchRequest{
        
        let fetchRequest = NSFetchRequest(entityName: "List")
        let primarySortDescription = NSSortDescriptor(key: "slcross", ascending: true)
        let secondarySortDescription = NSSortDescriptor(key: "slcategory", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescription, secondarySortDescription]
        fetchRequest.predicate = NSPredicate(format:"slist == true")
        return fetchRequest
    }
    
    func getFetchRequetController() ->NSFetchedResultsController{
        
        frc = NSFetchedResultsController(fetchRequest: itemFetchRequest(), managedObjectContext: moc, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        return frc
    }
    
    @IBOutlet weak var cartTotalLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var cartTotal: UILabel!
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
        self.cartTotal.textColor = UIColor.blackColor()
        self.cartTotalLabel.textColor = UIColor.blackColor()
        moveToPL.hidden = true
        cartTotal.hidden = true
        tableView.reloadData()
        
        //"edit" bar button item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editButtonPressed"))
    }//End viewDidLoad
    
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
    
//    func cartTotalFunc() {
//        
//        itemFetchRequest().returnsObjectsAsFaults = false
//        
//        do {
//            let results = try moc.executeFetchRequest(itemFetchRequest())
//            print("===\(results)")
//            
//            // Calculate the grand total.
//            var grandTotal = 0
//            for order in results {
//                let SLP = order.valueForKey("slprice") as! Int
//                let SLQ = order.valueForKey("slqty") as! Int
//                grandTotal += SLP * SLQ
//            }
//            print("\(grandTotal)")
//            cartTotal.text = "(\(grandTotal)" as String).double
//            
//        } catch let error as NSError {
//            print(error)
//        }
//        
//    }
//    
    //tableView Data
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40
    }
    //Header Background/Text Color
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        //header background color
        view.tintColor = UIColor.lightGrayColor() //background gray
        
        //header text color
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.blueColor() //text Blue
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = frc.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SLTableViewCell
        
        //assign delegate
        cell.delegate = self
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        cell.backgroundColor = UIColor.clearColor()
        cell.tintColor = UIColor.grayColor()
        cell.cellLabel.text = "\(items.slitem!) - \(items.slqty!) \(items.slsuffix!)"
        cell.cellLabel.font = UIFont.systemFontOfSize(25)
        moveToPL.hidden = true
        
        if (items.slcross == true) {
            cell.accessoryType = .Checkmark
            cell.cellLabel.textColor = UIColor.grayColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(20)
            self.tableView.rowHeight = 50
            //strikeThrough text
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: cell.cellLabel.text!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
//            cartTotalFunc()
            cell.cellLabel.attributedText = attributeString
            cartTotal.hidden = false
            moveToPL.hidden = false
            
        } else {
            cell.accessoryType = .None
            cell.cellLabel.textColor = UIColor.blackColor()
            cell.cellLabel.font = UIFont.systemFontOfSize(25)
            self.tableView.rowHeight = 60
            moveToPL.hidden = true
            cartTotal.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let items = frc.objectAtIndexPath(indexPath) as! List
        
        if (items.slcross == true) {
            items.slcross = false
        } else {
            items.slcross = true
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    @IBOutlet weak var moveToPL: UIButton!
    @IBAction func moveToPantry(sender: AnyObject) {
        
        let sectionInfo = self.frc.sections![self.frc.sections!.count - 1]
        
        let objectsToAppend = sectionInfo.objects as! [List]
        for item in objectsToAppend {
            item.plist = true
            item.pcross = false
            item.slist = false
            
            item.pitem = item.slitem
            item.pdesc = item.sldesc
            item.pprice = item.slprice
            item.pcategory = item.slcategory
            item.psuffix = item.slsuffix
            
            print(item)
            let myDouble = Double(item.slminqty!)
            let qtystepper = myDouble
            item.pminsteppervalue = qtystepper!
            
            item.pminstepperlabel = item.slminqty
    
            moveToPL.hidden = true
            
        //Handle qty discrepancies 
            if (item.pqty == nil){
                item.pqty = item.slqty
                let myInt0:Int = 0
                let myString0:String = String(myInt0)
                item.slqty = myString0
            }
            if (item.pitem == item.slitem) {
                //get value of string
                let stringNumber1 = item.slqty
                let stringNumber2 = item.pqty
                //convert string to Int
                let numberFromString1 = Int(stringNumber1!)
                let numberFromString2 = Int(stringNumber2!)
                //get sum of Int
                let sum = (numberFromString2)! + (numberFromString1)!
                let myInt:Int = sum
                //convert back Int back to string
                let myString:String = String(myInt)
                //delclare string as qty.
                item.pqty = myString
                
                let myInt0:Int = 0
                let myString0:String = String(myInt0)
                item.slqty = myString0
            }else{
                item.pqty = item.slqty
            }
            
        }
    }
    
    
    //Swipe between tabs
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            self.navigationController!.tabBarController!.selectedIndex = 1
        }
        if (sender.direction == .Right) {
            self.navigationController!.tabBarController!.selectedIndex = 3
        }
    }
    
    //delegate method
    func cellButtonTapped(cell: SLTableViewCell) {
        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
        selectedItem = frc.objectAtIndexPath(indexPath) as? List
        self.performSegueWithIdentifier("editItem", sender: self)
    }
    
    //segue to add/edit
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editItem" {
            let SListController:SLEdit = segue.destinationViewController as! SLEdit
            SListController.item = selectedItem
        }
    }
}