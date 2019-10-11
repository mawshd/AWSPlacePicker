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

struct AWSLocation {
    var id : String? //place id
    var postcode : String?
    var city : String?
    var country : String?
    var country_short : String?
    var latitude : Double?
    var longitude : Double?
    var address : String?
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




