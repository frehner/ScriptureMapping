//
//  FormTableViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 12/11/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit

class FormTableViewController : UITableViewController, UITextFieldDelegate{
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
