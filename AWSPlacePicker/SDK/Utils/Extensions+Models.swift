//
//  File.swift
//  AWSPlacePicker
//
//  Created by Awais Shahid on 11/10/2019.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

public struct AWSLocation {
    public var id : String? //place id
    public var postcode : String?
    public var city : String?
    public var country : String?
    public var country_short : String?
    public var latitude : Double?
    public var longitude : Double?
    public var address : String?
}

struct LOCATION_KEYS {
    static var LATITUDE = "latitude"
    static var LONGITUDE = "longitude"
    static var ADDRESS = "address"
    static var CITY = "city"
    static var COUNTRY = "country"
    static var POSTALCODE = "postalCode"
}

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}

extension AWSLocation {
    var coordinates : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude ?? 0, longitude: self.longitude ?? 0)
    }
}

extension CLLocationCoordinate2D {
    var location : CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension GMSAddress {
    var awsLocation : AWSLocation? {
        var loc = AWSLocation()
        loc.postcode = self.postalCode
        loc.city = self.locality
        loc.country = self.country
        loc.latitude = self.coordinate.latitude
        loc.longitude = self.coordinate.longitude
        loc.address = self.lines?.first
        return loc
    }
}


extension Bundle {
    class var json : Bundle? {
        if let url = Bundle(for: AWSPlacePicker.self).url(forResource: "SDKJsons", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
    class var xibs : Bundle? {
        if let url = Bundle(for: AWSPlacePicker.self).url(forResource: "SDKNibs", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
    class var images : Bundle? {
        if let url = Bundle(for: AWSPlacePicker.self).url(forResource: "SDKImages", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
}



extension UIImage {
    class func imageWith(name:String, ext: String = "png") -> UIImage {
        return UIImage(named: "\(name).\(ext)", in: Bundle.images, compatibleWith: nil) ?? UIImage()
    }
}

extension UIView {
    
    @IBInspectable var corner: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if newValue > 0 {
                layer.cornerRadius = newValue
            }
        }
    }
    
    @IBInspectable var border: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            if newValue > 0 {
                layer.borderWidth = newValue
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var circle: Bool {
        get {
            return layer.cornerRadius == bounds.size.height/2
        }
        set {
            if newValue {
                layer.cornerRadius = bounds.size.height/2
            }
        }
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return false
        }
        set {
            if newValue {
                layer.shadowOffset = CGSize(width: 0.85, height: 1.7)
                layer.borderColor = backgroundColor?.cgColor
                layer.shadowRadius = 3
                layer.shadowOpacity = 1
            }
        }
    }
    
}
