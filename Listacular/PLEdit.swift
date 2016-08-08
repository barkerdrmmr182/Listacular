//
//  PLEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class PLEdit: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var pitem: UITextField!
    @IBOutlet weak var pdesc: UITextField!
    @IBOutlet weak var pqty: UITextField!
    @IBOutlet weak var pprice: UITextField!
    @IBOutlet weak var psuffix: UITextField!
    @IBOutlet weak var pcategory: UITextField!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var item: List? = nil
    
    var pitemObserver: NSObjectProtocol!
    var ppriceObserver: NSObjectProtocol!
    var pqtyObserver: NSObjectProtocol!
    var pdescObserver: NSObjectProtocol!
    var psuffixObserver: NSObjectProtocol!
    var pcategoryObserver: NSObjectProtocol!
    
    //Picker Options
    var categoryPickOption = ["Baking", "Bread", "Breakfast", "Canned Foods", "Cleaning", "Dairy", "Deli", "Drinks", "Frozen", "Fruit","Kitchen", "Household", "Meats", "Pets", "Produce", "Snacks", "Other"]
    var suffixPickOption = ["bottle(s)","box(es)","can(s)","case(s)", "gallon(s)", "jar(s)", "lbs.", "of them", "package(s)", "other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //picker Delegate
        let categoryPickerView = UIPickerView()
        categoryPickerView.delegate = self
        pcategory.inputView = categoryPickerView
        
        let suffixPickerView = UIPickerView()
        suffixPickerView.delegate = self
        psuffix.inputView = suffixPickerView
        
        categoryPickerView.tag = 0
        suffixPickerView.tag = 1
        
        // item not nill means we're editing.
        if item != nil{
            updateUIFromItem()
        }
        
        // "x" Delete Feature
        self.pitem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pdesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pqty.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pprice.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.psuffix.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.pcategory.clearButtonMode = UITextFieldViewMode.WhileEditing
    
        pitemObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.pitem, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        pdescObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.pdesc, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        pqtyObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.pqty, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        ppriceObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.pprice, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        psuffixObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.psuffix, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        pcategoryObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.pcategory, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        
        // validate the form and apply it to save butotn.
        btnSave.enabled = formIsValid
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(pitemObserver)
        NSNotificationCenter.defaultCenter().removeObserver(pdescObserver)
        NSNotificationCenter.defaultCenter().removeObserver(pqtyObserver)
        NSNotificationCenter.defaultCenter().removeObserver(ppriceObserver)
        NSNotificationCenter.defaultCenter().removeObserver(psuffixObserver)
        NSNotificationCenter.defaultCenter().removeObserver(pcategoryObserver)
        
    }
    
    //Dismiss Keyboard when touched outside of textFields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func updateUIFromItem() {
        if let item = self.item {
            pitem.text = item.pitem
            pdesc.text = item.pdesc
            pqty.text = item.pqty
            pprice.text = item.pprice
            pcategory.text = item.pcategory
            psuffix.text = item.psuffix
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
        invAlert()
    }
    
    func invAlert () {
        if (item!.pminstepperlabel == nil) {
            let alert = UIAlertController(title: "Minimun Qty.", message: "Please set minimun qty. for pantry.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addTextFieldWithConfigurationHandler { [unowned self] (textField: UITextField!) -> Void in
                textField.placeholder = "Minimun Qty."
                textField.keyboardType = .NumbersAndPunctuation
                textField.clearButtonMode = UITextFieldViewMode.WhileEditing
                
                // observe the textField value to make the set button only enabled when it's not empty.
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { [unowned self] (notification) in
                    let textField = notification.object as! UITextField
                    self.item!.pminstepperlabel = textField.text
                    
                    self.setAction!.enabled = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty == false
                }
            }
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:{[unowned self] _ in self.saveToCoreDate()}))
            setAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default, handler: {[unowned self](action) -> Void in
                
                let textField = alert.textFields!.first as UITextField?
                self.item?.pminstepperlabel = textField!.text
                
                
                self.saveToCoreDate()})
            setAction?.enabled = false // initialy disabled
            
            alert.addAction(setAction!)
            self.presentViewController(alert, animated: true, completion: nil)
            dismissVC()
            
        }else{
            
            if item != nil {
                edititems()
            } else {
                createNewitem()
            }
            
            
            dismissVC()
        }
    }
    

    
    func saveitem(sender: AnyObject) {
        
        if item != nil {
            edititems()
        } else {
            createNewitem()
        }
        
        
        dismissVC()
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
        item.plist = true
        item.pcross = false
        
        item.pitem = pitem.text
        item.pqty = pqty.text
        item.pdesc = pdesc.text
        item.pprice = pprice.text
        item.psuffix = psuffix.text
        item.pcategory = pcategory.text
        
        item.pqtystepperlabel = item.pqty
        
        
        // assign the new item to self.item
        self.item = item
        print(item)
        
    }
    var formIsValid:Bool {
        // make sure all is not null.
        //TODO: you may check for the number values is only numbers too.
        return pitem.text?.isEmpty  == false
            && pdesc.text?.isEmpty  == false
            && pqty.text?.isEmpty   == false
            && pprice.text?.isEmpty == false
            && pcategory.text?.isEmpty == false
            && psuffix.text?.isEmpty == false
    }
    func updateItem() {
        
        // making sure item is not nil.
        if item == nil {
            createNewitem()
        }
        
        if formIsValid {
            
            // update the item with what in the text fields.
            item!.pitem = pitem.text
            item!.pdesc = pdesc.text
            item!.pqty = pqty.text
            item!.pprice = pprice.text
            item!.pcategory = pcategory.text
            item!.psuffix = psuffix.text
            
            
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
//here

    
//    func createitems() {
//        
//        let entityDescripition = NSEntityDescription.entityForName("List", inManagedObjectContext: moc)
//        
//        let item = List(entity: entityDescripition!, insertIntoManagedObjectContext: moc)
//        
//        item.pitem = pitem.text
//        item.pqty = pqty.text
//        item.pdesc = pdesc.text
//        item.pprice = pprice.text
//        item.psuffix = psuffix.text
//        item.pcategory = pcategory.text
//        item.plist = true
//        item.pcross = false
//        
////        if pitem.text == nil{
////            createitems()
////            
////        }else{
////            edititems()
////        }
////        
//        do {
//            try moc.save()
//        } catch _ {
//            return
//        }
//    }
    
    func edititems() {
        item?.pitem = pitem.text!
        item?.pqty = pqty.text!
        item?.pdesc = pdesc.text!
        item?.pprice = pprice.text!
        item?.psuffix = psuffix.text!
        item?.pcategory = pcategory.text!
        
        
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    //set up pickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return categoryPickOption.count
        }
        if pickerView.tag == 1 {
            return suffixPickOption.count
        }else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return categoryPickOption[row]
        }
        if pickerView.tag == 1 {
            return suffixPickOption[row]
        }else {
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            pcategory.text = categoryPickOption[row]
        }
        if pickerView.tag == 1 {
            psuffix.text = suffixPickOption[row]
        }
    }//end pickerView
}
