//
//  ViewController.swift
//  MapKitIOS
//
//  Created by Jim Pool Moreno on 15/01/21.
//

import UIKit
import MapKit
import CoreLocation
import MediaPlayer

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //MARK: --Out
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var distanceTxt: UITextField!
    
    
    //MARK: --MapKit
    let locationManager = CLLocationManager()
    var upmLocation = CLLocation()
    var regionHasBeenCentered = false
    
    //MARK: --UPM coordenates
    let upmLatitude = 40.3895335
    let upmLongitude = -3.6287317
    let radius = 150
    
    //MARK: --Video
    var player = AVPlayer()
    var intoCircle = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Authorize access to the device
        locationManager.requestWhenInUseAuthorization()
        //Accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //distance - filter
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        //
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        //_ = self.regionToMonitor()
        
        //mapView.delegate = self
        mapView.showsUserLocation = true
        
        viewVideo.backgroundColor = UIColor(red: 255, green: 0, blue: 255, alpha: 0.4)
        
        upmLocation = CLLocation.init(latitude: upmLatitude, longitude: upmLongitude)
        addRadiusCircle(location: upmLocation)
    
    }
    
    func addRadiusCircle(location: CLLocation){
            self.mapView.delegate = self
            let circle = MKCircle(center: location.coordinate, radius: 150 as CLLocationDistance)
            self.mapView.addOverlay(circle)
        }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKCircle {
                let circle = MKCircleRenderer(overlay: overlay)
                circle.strokeColor = UIColor.red
                circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
                circle.lineWidth = 1
                return circle
            } else {
                return MKOverlayRenderer()
            }
        }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        print("latitud: " , locations[0].coordinate.latitude, " -- longitude: " , locations[0].coordinate.longitude)
        print("locations = \(locations)") // Imprime las localizaciones
        
        
        searchIntoCircle(x: locations[0].coordinate.longitude, y: locations[0].coordinate.latitude, radius: Double(radius))
    }
    
    func searchIntoCircle(x : Double, y: Double, radius: Double){
        
        let distance = measure(lat1: y, lon1: x, lat2: upmLatitude, lon2: upmLongitude)
        print("distance in Km: ", String(format: "%.4f", distance/1000) )
        
        distanceTxt.text =  "Distance in Km: " + String(format: "%.7f", distance/1000)
        
        if(distance > radius){
            print("Out of circle")
            //intoCircle = false
            stopVideo()
            distanceTxt.textColor = UIColor.red
        }else{
            print("Into of circle")
            playvideo()
            distanceTxt.textColor = UIColor.blue
        }
        
    }
    
    func playvideo(){
        //avoid restart
        if(intoCircle == false){
            let audioPath = Bundle.main.path(forResource : "earth", ofType: "mp4")!
            // it didn't work
            //player = AVPlayer(url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!) // your video url
            player = AVPlayer(url: URL(
                fileURLWithPath: audioPath))
            let  playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.viewVideo.bounds
            playerLayer.videoGravity = .resizeAspectFill
            viewVideo.layer.addSublayer(playerLayer)
            player.play()
            intoCircle = true
        }else{
            player.play()
        }
    }
    
    func stopVideo(){
        player.pause()
        //player.currentItem = nil
    }
    
    ///Haversine_formula
    func measure(lat1 : Double, lon1 : Double, lat2 : Double, lon2 : Double) -> Double{
        // generally used geo measurement function
        let R = 6378.137; // Radius of earth in KM
        let dLat = lat2 * Double.pi / 180 - lat1 * Double.pi / 180;
        let dLon = lon2 * Double.pi / 180 - lon1 * Double.pi / 180;
        let a = sin(dLat/2) * sin(dLat/2) +
        cos(lat1 * Double.pi / 180) * cos(lat2 * Double.pi / 180) *
        sin(dLon/2) * sin(dLon/2);
        let c = 2 * atan2(sqrt(a), sqrt(1-a));
        let d = R * c;
        return d * 1000; // meters
    }

}

