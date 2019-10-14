//
//  ViewController.swift
//  AWSPlacePickerExample
//
//  Created by Awais Shahid on 11/10/2019.
//  Copyright © 2019 Awais Shahid. All rights reserved.
//

import UIKit
import AWSPlacePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    
    @IBAction func selectLocation(_ sender: UIButton) {
        AWSPlacePicker.shared.API_KEY = "";
        AWSPlacePicker.shared.pickLocationFrom(from: self, onLocationSelection: { (loc) in
            sender.setTitle(loc?.address, for: .normal)
        }, onCancellation: nil)
    }
    
}

