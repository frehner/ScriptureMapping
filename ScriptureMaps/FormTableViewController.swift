//
//  FormTableViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 12/11/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class FormTableViewController : UITableViewController, UITextFieldDelegate{
    // MARK: - Outlets
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var viewLatitude: UITextField!
    @IBOutlet weak var viewLongitude: UITextField!
    @IBOutlet weak var viewTilt: UITextField!
    @IBOutlet weak var viewRoll: UITextField!
    @IBOutlet weak var viewAltitude: UITextField!
    @IBOutlet weak var viewHeading: UITextField!
    
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let nextField = view.viewWithTag(textField.tag + 1) {
            nextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.selectAll(nil)
    }
}
