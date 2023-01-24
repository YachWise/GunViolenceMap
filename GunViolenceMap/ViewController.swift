//
//  ViewController.swift
//  GunViolenceMap
//
//  Created by Jacob Wise on 1/22/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var mapView: MKMapView!
    
    //MARK: - Local Variables
    
    var shootings = [MassShootingStruct]()
    
    //MARK: - Local Functions
    private func returnPlacemark(address: String) -> CLPlacemark
    {
        var returnPlacemark: CLPlacemark?
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarkArr, error in
            if let placemark = placemarkArr?.first
            { returnPlacemark = placemark }
            }
        return returnPlacemark!
    }
    func getLocation(from address: String, completion: @escaping (_ location: CLLocationCoordinate2D?)-> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks,
            let location = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(location)
        }
    }
    private func readShootingCSV()
    {
        guard let filePath = Bundle.main.path(forResource: "mass_shootings", ofType: "csv") else { return }
        
        var data: String?
        do
        {
            data = try String(contentsOfFile: filePath)
        }
        catch
        {
            print(error)
            return
        }
        //separate by new line
        var rows = data!.components(separatedBy: "\n")
        //first row tells what make the struct
        rows.removeFirst()
        
        for row in rows{
            //an arr of each row separated by columns
            let columns = row.components(separatedBy: ",")
            
            if columns.count == 1
            {
                //do nutn
            }
            else
            {
               
                let annotation = MKPointAnnotation()
                
                let incident_id = columns[0]
                let month_day = columns[1]
                let year = columns[2]
                let fullDate = "\(month_day) \(year)"
                let state = columns[3]
                let city = columns[4]
                let address = columns[5]
                let fullAddress = "\(address), \(city), \(state)"
                let n_killed = Int(columns[6]) ?? 0
                let n_injured = Int(columns[7]) ?? 0
                
            
                let shooting = MassShootingStruct(incident_id: incident_id, date: fullDate, state: state, city: city, address: address, n_killed: n_killed, n_injured: n_injured)
                self.shootings.append(shooting)
                
                let returnedMark = getLocation(from: fullAddress) { location in
                    if location != nil
                    {
                        annotation.coordinate.longitude = location!.longitude
                        annotation.coordinate.latitude = location!.latitude
                    }
                  
                }
                
                
                self.mapView.addAnnotation(annotation)

            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.readShootingCSV()
        // Do any additional setup after loading the view.
    }


}

