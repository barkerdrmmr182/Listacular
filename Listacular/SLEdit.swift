//
//  SLEdit.swift
//  Listacular
//
//  Created by Will Zimmer on 12/10/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

class SLEdit: UIViewController {

    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    @IBOutlet weak var slitem: UITextField!
    @IBOutlet weak var sldesc: UITextField!
    @IBOutlet weak var slqty: UITextField!
    @IBOutlet weak var slprice: UITextField!
    
	@IBOutlet weak var btnSave: UIBarButtonItem!


    var item: List? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

		// item not nill means we're editing.
        if item != nil{
			updateUIFromItem()
		}

        // "x" Delete Feature
        self.slitem.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.sldesc.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slqty.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.slprice.clearButtonMode = UITextFieldViewMode.WhileEditing

		slitem.delegate  = self
		sldesc.delegate  = self
		slqty.delegate   = self
		slprice.delegate = self
		// validate the form and apply it to save butotn.
		btnSave.enabled = formIsValid
    }
	func updateUIFromItem() {
		if let item = self.item {
			slitem.text  = item.slitem
			sldesc.text  = item.sldesc
			slqty.text   = item.slqty
			slprice.text = item.slprice
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
				self.item?.slminqty = textField?.text


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
			print(item?.slminqty)

			dismissVC()
        }
        }

    func saveitem(sender: AnyObject) {

        if item != nil {
            edititems()
        } else {
            createitems()
        }
        print(item?.slminqty)
        
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
		item.slist = true
		item.slcross = false
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
        item.slist = true
        item.slcross = false

		// why calling the function itself inside its own code it will be called for ever if slitem.text is nil.
        if slitem.text == nil{
//            createitems()

        }else{
			/*
			why calling edite here i see the edit code is
			item?.slitem = slitem.text!
			item?.sldesc = sldesc.text!
			item?.slqty = slqty.text!
			item?.slprice = slprice.text!
			
			
			which is exactly the same to what the method just doen ABOVE.
			*/
//            edititems()
        }
        
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
        
        do {
            try moc.save()
        } catch {
            return
        }
    }
    
    
}
extension SLEdit : UITextFieldDelegate {
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		// check for tha form validation and apply it for the save button.
//		btnSave.enabled = formIsValid
		return true
	}
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		return formIsValid
	}
	func textFieldDidEndEditing(textField: UITextField) {
		btnSave.enabled = formIsValid
	}
}

