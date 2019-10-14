//
//  HelperUtils.swift
//  AWSPlacePicker
//
//  Created by Awais Shahid on 11/10/2019.
//

import UIKit
import Foundation
import DropDown
import GoogleMaps
import IQKeyboardManagerSwift

var GOOGLE_API_KEY = ""

protocol AWSPlacePickerTextFieldDelegate {
    func didSelectLocationFor (textField : AWSPlacePickerTextField, location : String)
    func didSelectedAWSLocationFor (textField : AWSPlacePickerTextField, location : AWSLocation)
    func textDidChangeFor (textField : AWSPlacePickerTextField, text : String)
    func textFieldCleared (textField : AWSPlacePickerTextField)
}

extension AWSPlacePickerTextFieldDelegate {
    func textDidChangeFor (textField : AWSPlacePickerTextField, text : String) {}
    func textFieldCleared (textField : AWSPlacePickerTextField) {}
}

class AWSPlacePickerTextField : UITextField {
    
    var AWSdelegate : AWSPlacePickerTextFieldDelegate?
    var shouldSearchOnlyCities = false
    
    private var shouldShow = false
    lazy var dropDown : DropDown = {
        return DropDown()
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearButtonMode = .whileEditing
        self.returnKeyType = .search
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    @objc private func textFieldDidEndEditing(){
        shouldShow = false
    }

    @objc private func textFieldDidChange(){
        shouldShow = true
        guard let txt = text else {
            return
        }
        startFindingPlaces(text: txt)
        AWSdelegate?.textDidChangeFor(textField: self, text: txt)
    }
    
    private func startFindingPlaces (text : String) {
        
        if text.isEmpty {
            AWSdelegate?.textFieldCleared(textField: self)
            return
        }
        
        var dataTask:URLSessionDataTask?
        
        if let dataTask1 = dataTask { dataTask1.cancel()}
        var params : [String : Any] = [
            "key" : GOOGLE_API_KEY,
            "input" : text,
            "components" : "country:PK"
        ]
        if shouldSearchOnlyCities {
            params["types"] = "(cities)"
        }
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?\(params.queryString)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        let request = URLRequest(url: url)
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data{
                do {
                    if let result = try JSONSerialization.jsonObject(with: data) as? [String:Any] {
                        if let status = result["status"] as? String {
                            if status == "OK" {
                                if let predictions = result["predictions"] as? NSArray {
                                    var places = [AWSLocation]()
                                    for dict in predictions as? [NSDictionary] ?? [] {
                                        var place = AWSLocation()
                                        place.id =  dict["place_id"] as? String
                                        place.address = dict["description"] as? String
                                        places.append(place)
                                    }
                                    DispatchQueue.main.async {
                                        self.setUpDropDown(places)
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
                catch let error as NSError{
                    print("Error: \(error.localizedDescription)")
                }
            }
        })
        dataTask?.resume()
    }
    
    private func getPlaceDetailsByID(id : String) {
        var dataTask:URLSessionDataTask?
        if let dataTask1 = dataTask { dataTask1.cancel() }
        let params : [String : Any] = [
            "key" : GOOGLE_API_KEY,
            "placeid" : id
        ]
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?\(params.queryString)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        let request = URLRequest(url: url)
        
        dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let data = data{
                do{
                    var place = AWSLocation()
                    if let result1 = try JSONSerialization.jsonObject(with: data) as? [String:Any] {
                        
                        if let status = result1["status"] as? String {
                            if status == "OK" {
                                if let result = result1["result"] as? NSDictionary {
                                    
                                    if let address_components = result["address_components"] as? [NSDictionary] {
                                        for dict in address_components {
                                            let types = dict["types"] as? [String] ?? []
                                            for type in types {
                                                if type  == "postal_code" {
                                                    place.postcode = dict["long_name"] as? String
                                                }
                                                else if type == "locality" || types[0] == "administrative_area_level_2" {
                                                    place.city = dict["long_name"] as? String
                                                }
                                                else if type == "country" {
                                                    place.country = dict["long_name"] as? String
                                                    place.country_short = dict["short_name"] as? String
                                                }
                                            }
                                        }
                                    }
                                    
                                    if let place_id = result["place_id"] as? String {
                                        place.id = place_id
                                    }
                                    
                                    if let name = result["formatted_address"] as? String {
                                        place.address = name
                                    }
                                    
                                    if let geometery = result["geometry"] as? NSDictionary {
                                        if let loc = geometery["location"] as? NSDictionary {
                                            place.latitude = loc["lat"] as? Double
                                            place.longitude = loc["lng"] as? Double
                                        }
                                    }
                                    
                                    self.AWSdelegate?.didSelectedAWSLocationFor(textField: self, location: place)
                                    return
                                }
                            }
                        }
                    }
                }
                catch let error as NSError{
                    print("Error: \(error.localizedDescription)")
                }
            }
        })
        dataTask?.resume()
    }
    
    private func setUpDropDown (_ array : [AWSLocation]?) {
        
        if shouldShow == false { return }
        guard let ary = array else { return }
        if ary.count == 0 { return }
        
        dropDown.anchorView = self
        dropDown.width = self.bounds.width
        
        let strAry = ary.compactMap { (location) -> String? in
            return location.address
        }
        
        dropDown.dataSource = strAry
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y:-self.bounds.height)
        dropDown.cellNib = UINib(nibName: "DropDownCustomCell", bundle: Bundle.xibs)
        
        dropDown.selectionAction = { (index: Int, item: String) in
            self.text=item
            self.dropDown.hide()
            let aryIndex = ary.firstIndex(where: { (location) -> Bool in
                return location.address == item
            })
            self.getPlaceDetailsByID(id: ary[aryIndex ?? 0].id ?? "")
            self.AWSdelegate?.didSelectLocationFor(textField: self, location: item)
        }
        dropDown.show()
    }
}


class AWSLocationManager : NSObject {
    
    static let shared = AWSLocationManager()
    
    fileprivate var locationManager : CLLocationManager?
    fileprivate (set) var permission : (granted : Bool, status : String) = (false, "not configured")
    fileprivate var trackLocations: ((_ location : CLLocation) -> ())? = nil
    
    fileprivate (set) var latitude : Double {
        get { return UserDefaults.standard.double(forKey: LOCATION_KEYS.LATITUDE) }
        set { UserDefaults.standard.set(newValue, forKey: LOCATION_KEYS.LATITUDE) }
    }
    
    fileprivate (set) var longitude : Double {
        get { return UserDefaults.standard.double(forKey: LOCATION_KEYS.LONGITUDE) }
        set { UserDefaults.standard.set(newValue, forKey: LOCATION_KEYS.LONGITUDE) }
    }
    
    fileprivate (set) var address : String {
        get { return (UserDefaults.standard.value(forKey: LOCATION_KEYS.ADDRESS) as? String) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: LOCATION_KEYS.ADDRESS) }
    }
    
    fileprivate (set) var city : String {
        get { return (UserDefaults.standard.value(forKey: LOCATION_KEYS.CITY) as? String) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: LOCATION_KEYS.CITY) }
    }
    
    fileprivate (set) var location : CLLocation {
        get { return CLLocation(latitude: latitude, longitude: longitude) }
        set {  }
    }
    
    private override init() {
        super.init()
        registerForLocationServices()
    }
    
    private func registerForLocationServices() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestLocation()
        locationManager?.distanceFilter = 25
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        //locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager?.startUpdatingHeading()
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingHeading()
        locationManager?.stopUpdatingLocation()
    }
    
    func trackLocationChanges(updatedLocation: @escaping(_ loc:CLLocation)->Void ) {
        trackLocations = updatedLocation
    }
    
    fileprivate func setUpAWSLocation(placemark : CLPlacemark) {
        var components = [String]()
        if let subThroughFare = placemark.subThoroughfare, !subThroughFare.isEmpty {
            components.append(subThroughFare)
        }
        if let throughFare = placemark.thoroughfare, !throughFare.isEmpty {
            components.append(throughFare)
        }
        if let subLocality = placemark.subLocality, !subLocality.isEmpty {
            components.append(subLocality)
        }
        if let locality = placemark.locality, !locality.isEmpty {
            components.append(locality)
        }
        
        self.address = components.joined(separator:", ")
        self.city = placemark.locality ?? ""
    }
    
}



extension AWSLocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        //setupLocationByApple(location: manager.location!)
        setupLocationByGoogle(location: location)
        trackLocations?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        permission.granted = false
        
        switch status {
        case .restricted:
            permission.status = "restricted"
        case .denied:
            permission.status = "denied"
        case .authorizedAlways:
            permission.granted = true
            permission.status = "authorized always"
        case .authorizedWhenInUse:
            permission.granted = true
            permission.status = "when in use"
        default:
            permission.status = "not determined"
        }
        
        if permission.granted {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}


extension AWSLocationManager {
    fileprivate func setupLocationByApple(location : CLLocation) {
        AWSLocationManager.reverseGeocodeByApple(location) { (placemark) in
            self.setUpAWSLocation(placemark: placemark)
        }
    }
    
    class func geocodeByApple (address: String, completion: @escaping (_ placemark: CLPlacemark) -> Void) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) -> Void in
            if let placemark = placemarks?.first {
                completion(placemark)
                return
            }
            print(error?.localizedDescription ?? "")
        })
    }
    
    class func reverseGeocodeByApple (_ location:CLLocation, completion: @escaping (_ placemark: CLPlacemark) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let placemark = placemarks?.first {
                completion(placemark)
                return
            }
            print(error?.localizedDescription ?? "")
        })
    }
}

extension UIApplication {
    class func setupInitials() {
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        IQKeyboardManager.shared.enable = true
    }
}

extension AWSLocationManager {
    
    fileprivate func setupLocationByGoogle(location : CLLocation) {
        AWSLocationManager.reverseGeocodeByGoogle(location) { (gAdress) in
            if let adrs = gAdress.lines?.first {
                self.address = adrs
            }
            else {
                var components = [String]()
                if let throughFare = gAdress.thoroughfare, !throughFare.isEmpty {
                    components.append(throughFare)
                }
                if let subLocality = gAdress.subLocality, !subLocality.isEmpty {
                    components.append(subLocality)
                }
                if let locality = gAdress.locality, !locality.isEmpty {
                    components.append(locality)
                }
                self.address = components.joined(separator:", ")
            }
            self.city = gAdress.locality ?? ""
        }
    }
    
    class func reverseGeocodeByGoogle (_ location:CLLocation, completion: @escaping (_ gmsAddress: GMSAddress) -> Void) {
        GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (response, error) in
            if let adress = response?.firstResult() {
                completion(adress)
            }
        }
    }
}



class HelperUtils {
    
    class func loadJson(fileName : String) -> (dic:[String:Any]?, ary:[[String:Any]]?) {
        if let filePath = Bundle.json?.path(forResource: fileName, ofType: "json"), let data = NSData(contentsOfFile: filePath) {
            let dic = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
            if let ary = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:Any]] {
                return(dic, ary)
            }
            return(dic, nil)
        }
        return (nil,nil)
    }
    
    class func getMapStyle() -> String {
        let stylesAry = HelperUtils.loadJson(fileName: "MapStyle").ary
        return HelperUtils.getJsonString(from: stylesAry ?? [:])
    }

    class func getJsonString(from obj: Any) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return jsonString.filter { !" \n\t\r".contains($0) }
        } catch {
            return error.localizedDescription
        }
    }
}
