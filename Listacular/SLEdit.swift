//
//  SLEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData
@objc

class SLEdit: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var slitem: UITextField!
    @IBOutlet weak var sldesc: UITextField!
    @IBOutlet weak var slqty: UITextField!
    @IBOutlet weak var slprice: UITextField!
    @IBOutlet weak var slsuffix: UITextField!
    @IBOutlet weak var slcategory: UITextField!
    
	@IBOutlet weak var btnSave: UIBarButtonItem!

    var item: List? = nil
    
    var slitemObserver: NSObjectProtocol!
    var slpriceObserver: NSObjectProtocol!
    var slqtyObserver: NSObjectProtocol!
    var sldescObserver: NSObjectProtocol!
    var slsuffixObserver: NSObjectProtocol!
    var slcategoryObserver: NSObjectProtocol!
    
    //pickerOption array.
    var categoryPickOption = ["Baking", "Bread", "Breakfast", "Canned Foods", "Cleaning", "Dairy", "Deli", "Drinks", "Frozen", "Fruit","Kitchen", "Household", "Meats", "Pets", "Produce", "Snacks", "Other"]
    var suffixPickOption = ["bottle(s)","box(es)","can(s)","case(s)", "gallon(s)", "jar(s)", "lbs.", "of them", "package(s)", "other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //textField Delegates
        slprice.delegate = self
        slqty.delegate = self
        
        //picker Delegate
        let categoryPickerView = UIPickerView()
        categoryPickerView.delegate = self
        slcategory.inputView = categoryPickerView
        
        let suffixPickerView = UIPickerView()
        suffixPickerView.delegate = self
        slsuffix.inputView = suffixPickerView
        
        categoryPickerView.tag = 0
        suffixPickerView.tag = 1
        
		// item not nill means we're editing.
        if item != nil{
			updateUIFromItem()
		}

        // "x" Delete Feature
        self.slitem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.sldesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slqty.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slprice.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slsuffix.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slcategory.clearButtonMode = UITextFieldViewMode.WhileEditing
		
        slitemObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.slitem!, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        sldescObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.sldesc, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        slqtyObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.slqty, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
                self.btnSave.enabled = self.formIsValid
            
            })
        slpriceObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.slprice, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        slsuffixObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.slsuffix, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })
        slcategoryObserver = NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: self.slcategory, queue: NSOperationQueue.mainQueue(), usingBlock: { [unowned self] (notification) in
            self.btnSave.enabled = self.formIsValid
            
            })

		// validate the form and apply it to save butotn.
		btnSave.enabled = formIsValid
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(slitemObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(sldescObserver!)
        NSNotificationCenter.defaultCenter().removeObserver(slqtyObserver)
        NSNotificationCenter.defaultCenter().removeObserver(slpriceObserver)
        NSNotificationCenter.defaultCenter().removeObserver(slsuffixObserver)
        NSNotificationCenter.defaultCenter().removeObserver(slcategoryObserver)
        
    }
    
    //Dismiss Keyboard when touched outside of textFields
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
	
	func updateUIFromItem() {
		if let item = self.item {
			slitem.text = item.slitem
			sldesc.text = item.sldesc
			slqty.text = item.slqty
			slprice.text = item.slprice
            slcategory.text = item.slcategory
            slsuffix.text = item.slsuffix
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
        if (item!.slminqty == nil) {
			let alert = UIAlertController(title: "Minimun Qty.", message: "Please set minimun qty. for pantry.", preferredStyle: UIAlertControllerStyle.Alert)

			alert.addTextFieldWithConfigurationHandler { [unowned self] (textField: UITextField!) -> Void in
				textField.placeholder = "Minimun Qty."
				textField.keyboardType = .NumbersAndPunctuation
				textField.clearButtonMode = UITextFieldViewMode.WhileEditing

				// observe the textField value to make the set button only enabled when it's not empty.
				NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { [unowned self] (notification) in
					let textField = notification.object as! UITextField

					self.setAction!.enabled = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty == false
				}
			}

			alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:{[unowned self] _ in self.saveToCoreDate()}))
			setAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.Default, handler: {[unowned self](action) -> Void in

				let textField = alert.textFields!.first as UITextField?
				self.item?.slminqty = textField!.text
                
            
                    self.saveToCoreDate()})
			setAction?.enabled = false // initialy disabled

			alert.addAction(setAction!)
			self.presentViewController(alert, animated: true, completion: nil)

		}else{

			if item != nil {
				edititems()
			} else {
				createitems()
			}
			dismissVC()
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
		item.slist = true
		item.slcross = false
        
        item.slitem = slitem.text
        item.sldesc = sldesc.text
        item.slqty = slqty.text
        item.slprice = slprice.text
        item.slcategory = slcategory.text
        item.slsuffix = slsuffix.text
        
		// assign the new item to self.item
		self.item = item

	}
	var formIsValid:Bool {
		// make sure all is not null. 
		//TODO: you may check for the number values is only numbers too.
		return slitem.text?.isEmpty  == false
			&& sldesc.text?.isEmpty  == false
			&& slqty.text?.isEmpty   == false
			&& slprice.text?.isEmpty == false
            && slcategory.text?.isEmpty == false
            && slsuffix.text?.isEmpty == false
        
    }
    
	func updateItem() {

		// making sure item is not nil.
		if item == nil {
			createNewitem()
		}

		if formIsValid {

			// update the item with what in the text fields.
			item!.slitem = slitem.text
			item!.sldesc = sldesc.text
			item!.slqty = slqty.text
			item!.slprice = slprice.text
            item!.slcategory = slcategory.text
            item!.slsuffix = slsuffix.text
            
            
            
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
        
        item.slitem = slitem.text
        item.sldesc = sldesc.text
        item.slqty = slqty.text
        item.slprice = slprice.text
        item.slcategory = slcategory.text
        item.slsuffix = slsuffix.text
        item.slist = true
        item.slcross = false
        
        do {
            try moc.save()
        } catch _ {
            return
        }
    }
    
    func edititems() {
        item?.slitem = slitem.text!
        item?.sldesc = sldesc.text!
        item?.slqty = slqty.text!
        item?.slprice = slprice.text!
        item?.slcategory = slcategory.text!
        item?.slsuffix = slsuffix.text!
        
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
        slcategory.text = categoryPickOption[row]
        }
        if pickerView.tag == 1 {
        slsuffix.text = suffixPickOption[row]
    }
    }//end pickerView
    
}


