//
//  AWSPlacePicker.swift
//  Pods-AWSPlacePickerExample
//
//  Created by Awais Shahid on 11/10/2019.
//

import UIKit
import Foundation
import GoogleMaps
public class AWSPlacePicker : NSObject {
    public static let shared = AWSPlacePicker()
    public var API_KEY = ""

    override init() {
        
    }
    
    public func pickLocationFrom(from: UIViewController?, selectedLocation : AWSLocation? = nil, onLocationSelection:@escaping (AWSLocation?)->(), onCancellation: (() -> ())? = nil) {
        if API_KEY.isEmpty {
            fatalError("Google API Key required")
        }
        GOOGLE_API_KEY = self.API_KEY
        UIApplication.setupInitials()
        let vc = AWSPlacePickerVC.init(nibName: "AWSPlacePickerVC", bundle: Bundle.xibs)
        vc.selectedLocation = selectedLocation
        vc.onLocationSelection = onLocationSelection
        from?.present(vc, animated: true, completion: nil)
    }
}
