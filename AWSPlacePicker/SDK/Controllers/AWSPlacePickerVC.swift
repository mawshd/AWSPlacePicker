//
//  AWSPlacePickerVC.swift
//  Pods-AWSPlacePickerExample
//
//  Created by Awais Shahid on 11/10/2019.
//

import UIKit
import GoogleMaps

class AWSPlacePickerVC: UIViewController , AWSPlacePickerTextFieldDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView?
    @IBOutlet weak var textField: AWSPlacePickerTextField?
    @IBOutlet weak var marker: UIImageView?
    
    private var animate = false
    var selectedLocation : AWSLocation?
    
    var onLocationSelection: ((_ location : AWSLocation?) -> ())? = nil
    var onCancellation: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField?.AWSdelegate = self
        mapView?.delegate = self
        self.mapView?.mapStyle = try? GMSMapStyle(jsonString: HelperUtils.getMapStyle())
        
        self.marker?.image = UIImage.imageWith(name: "marker")
        
        if let loc = selectedLocation {
            self.animateMapToCoords(coords: loc.coordinates)
            self.textField?.text = loc.address
        }
        else {
            self.animateMapToCoords(coords: AWSLocationManager.shared.location.coordinate)
            AWSLocationManager.reverseGeocodeByGoogle(AWSLocationManager.shared.location) { [weak self] (adress) in
                self?.selectedLocation = adress.awsLocation
                self?.textField?.text = self?.selectedLocation?.address
            }
        }
    }
    
    func animateMapToCoords(coords : CLLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            self?.animate = true
            self?.mapView?.animate(toLocation: coords)
            let camera = GMSCameraPosition.camera(withTarget: coords, zoom: 16)
            self?.mapView?.camera = camera;
        }
    }
    
    func didSelectLocationFor(textField: AWSPlacePickerTextField, location: String) {
        self.selectedLocation = nil
    }
    
    func didSelectedAWSLocationFor(textField: AWSPlacePickerTextField, location: AWSLocation) {
        DispatchQueue.main.async { [weak self] in
            self?.animate = true
            let coords = CLLocationCoordinate2D (latitude: location.latitude ?? 0, longitude: location.longitude ?? 0)
            self?.mapView?.animate(toLocation: coords)
            let camera = GMSCameraPosition.camera(withTarget: coords, zoom: 16)
            self?.mapView?.camera = camera;
            self?.selectedLocation = location
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if animate {
            animate = false
            return
        }
        AWSLocationManager.reverseGeocodeByGoogle(position.target.location) { [weak self] (adress) in
            self?.selectedLocation = adress.awsLocation
            self?.textField?.text = adress.lines?.first
        }
    }
    

    @IBAction func DoneTapped(_ sender: Any) {
        if self.selectedLocation != nil {
            self.dismiss(animated: true, completion: {
                self.onLocationSelection?(self.selectedLocation)
            })
        }
    }
}
