//
//  AWSMapVC.swift
//  Pods-AWSPlacePickerExample
//
//  Created by Awais Shahid on 11/10/2019.
//

import UIKit
import GoogleMaps
import GooglePlaces

class AWSMapVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchTF: AWSPlacePickerTextField!
    var animate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.AWSdelegate = self
        mapView.delegate = self
    }
}

extension AWSMapVC : AWSPlacePickerDelegate {
    func didSelectLocationFor(textField: AWSPlacePickerTextField, location: String) {
        animate = true
        searchTF.endEditing(true)
    }
    
    func didSelectedAWSLocationFor(textField: AWSPlacePickerTextField, location: AWSLocation) {
        DispatchQueue.main.async { [weak self] in
            let coords = CLLocationCoordinate2D (latitude: location.latitude ?? 0, longitude: location.longitude ?? 0)
            self?.mapView.animate(toLocation: coords)
            let camera = GMSCameraPosition.camera(withTarget: coords, zoom: 16)
            self?.mapView.camera = camera;
        }
    }
}

extension AWSMapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if animate {
            animate = false
            return
        }
        AWSLocationManager.reverseGeocodeByGoogle(position.target.location) { (adress) in
            self.searchTF.text = adress.lines?.first
        }
    }
}

