//
//  TDEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class TDEdit: UIViewController {
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var tditem: UITextField!
    @IBOutlet weak var tddesc: UITextField!
    @IBOutlet weak var tddate: UIDatePicker!
    @IBOutlet weak var tdDoneLabel: UILabel!
    @IBOutlet weak var setDateButton: UIButton!
    @IBOutlet weak var changeDate: UIButton!
    
    var item: List? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item != nil{
            tditem.text = item?.tditem
            tddesc.text = item?.tddesc
            tdDoneLabel.text = item?.tddate
            
        }
        
        // "x" Delete Feature
        self.tditem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.tddesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        if (item?.tddate == nil){
            tdDoneLabel.text = "Enter Date"
            tddate.hidden = true
            setDateButton.hidden = false
            changeDate.hidden = true
        }else{
        tdDoneLabel.text = item!.tddate
            setDateButton.hidden = true
            changeDate.hidden = false
            tddate.hidden = true
        }
        let currentDate = NSDate()  //5 -  get the current date
        tddate.minimumDate = currentDate
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
    
    @IBAction func changeDate(sender: AnyObject) {
        tddate.hidden = false
        setDateButton.hidden = true
        changeDate.hidden = true
    }
    @IBAction func setDateButtonPressed(sender: AnyObject) {
        setDateButton.hidden = true
        tddate.hidden = false
    }
    
    @IBAction func doneBy(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm a"
        let strDate = dateFormatter.stringFromDate(tddate.date)
        self.tdDoneLabel.text = strDate
    }
    
    @IBAction func saveButton(sender: AnyObject) {
        
        if item != nil {
            edititems()
        } else {
            createitems()
        }
        
        dismissVC()
    }
    
    func createitems() {
        
        let entityDescripition = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
        
        let item = List(entity: entityDescripition!, insertIntoManagedObjectContext: moc)
        
        item.tditem = tditem.text
        item.tddesc = tddesc.text
        item.tdtime = tdDoneLabel.text
        item.tddate = tdDoneLabel.text
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
        item?.tdtime = tdDoneLabel.text!
        item?.tddate = tdDoneLabel.text!
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
}
