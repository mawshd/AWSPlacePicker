//
//  AWSPlacePicker.swift
//  Pods-AWSPlacePickerExample
//
//  Created by Awais Shahid on 11/10/2019.
//

import UIKit
import Foundation

open class AWSPlacePicker : NSObject {
    static let shared = AWSPlacePicker()
    let API_KEY = ""

    private override init() {
        
    }
    
    func pickLocationFrom(from: UIViewController, onLocationSelection:@escaping (AWSLocation)->(), onCancellation: (() -> ())? = nil) {
        if API_KEY.isEmpty {
            fatalError("Google API Key required")
        }
        GOOGLE_API_KEY = self.API_KEY
        let vc = AWSMapVC.init(nibName: "AWSMapVC", bundle: nil)
        from.present(vc, animated: true, completion: nil)
    }
}
