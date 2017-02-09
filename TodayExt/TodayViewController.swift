//
//  TodayViewController.swift
//  TodayExt
//
//  Created by Parth Dubal on 12/22/16.
//  Copyright © 2016 Parth Dubal. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

let kLName = "keyLocationName"
let kValue = "keyTemperature"
let kLat = "keyLat"
let kLong = "keyLong"
let kType = "keyType"

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class TodayViewController: UIViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblType: UILabel!
    let gUserDefault = UserDefaults.standard;
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblLocationName: UILabel!
    private var locationManager:CLLocationManager?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        lblTemp.text = "";
        lblLocationName.text = "";
        lblType.text = "";
        
        
        locationManager = CLLocationManager();
        locationManager?.delegate = self;
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager?.distanceFilter = 500;
        locationManager?.requestWhenInUseAuthorization();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.setDefaultValues();
        locationManager?.startUpdatingLocation();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setDefaultValues()
    {
        self.lblLocationName.adjustsFontSizeToFitWidth = true;
        self.lblType.adjustsFontSizeToFitWidth = true;
        
        self.lblLocationName.numberOfLines = 0;
        self.lblType.numberOfLines = 0;
        
        if let name = gUserDefault.string(forKey: kLName)
        {
            lblLocationName.text = name
        }
        if let temp = gUserDefault.string(forKey: kValue)
        {
            lblTemp.text = tempFormatValue(strTemp: temp);
        }
        if let type = gUserDefault.string(forKey: kType)
        {
            lblType.text = type;
        }
    }
    func tempFormatValue(strTemp:String) -> String
    {
        return strTemp+" °c";
    }
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        NSLog("DATA:: %@", #function);
        self.setDefaultValues();
        locationManager?.startUpdatingLocation();
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero;
    }
    
    
    //MARK: **Location Deleagate**
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        NSLog("error %@", error as? NSError ?? "other error.");
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation();
        if let currentLocation = locations.first
        {
            self.currentLocation(currentLocation: currentLocation);
        }
    }
    func currentLocation(currentLocation:CLLocation)
    {
        // CHECK LOCATION CHANGE VALUE AND UPDATE UI
        
        var lat = gUserDefault.double(forKey: kLat);
        var long = gUserDefault.double(forKey: kLong);
        
        if (lat != currentLocation.coordinate.latitude.roundTo(places: 6)) || (long != currentLocation.coordinate.longitude.roundTo(places: 6))
        {
//            lat = currentLocation.coordinate.latitude.roundTo(places: 6);
//            long = currentLocation.coordinate.longitude.roundTo(places: 6);
//            self.gUserDefault.set(lat, forKey: kLat);
//            self.gUserDefault.set(long, forKey: kLong);
//            self.gUserDefault.synchronize();
//            self.findTemp(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude);
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placeMarks:[CLPlacemark]?, error:Error?) in
                
                if let newError = error as? NSError
                {
                    NSLog("error: %@", newError);
                    return;
                }
                
                if let placemark = placeMarks?[0]
                {
                    var finalName = placemark.name!+", ";
                    
                    if let loc = placemark.subLocality
                    {
                        finalName += loc+", ";
                    }
                    if let loc = placemark.locality
                    {
                        finalName += loc+", ";
                    }
                    if let loc = placemark.subAdministrativeArea
                    {
                        finalName += loc+", ";
                    }
                    if let loc = placemark.administrativeArea
                    {
                        finalName += loc+".";
                    }
                    
                    
                    print("name: \(finalName)");
                    
                    self.gUserDefault.set(finalName, forKey: kLName);
                    
                    self.lblLocationName.text = finalName;
                    lat = currentLocation.coordinate.latitude.roundTo(places: 4);
                    long = currentLocation.coordinate.longitude.roundTo(places: 4);
                    
                    self.gUserDefault.set(lat, forKey: kLat);
                    self.gUserDefault.set(long, forKey: kLong);
                    self.gUserDefault.synchronize();
                    
                    self.findTemp(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude);
                    
                    
                }
            })
        }
        else
        {
            self.findTemp(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude);
        }
    }
    
    func findTemp(lat:Double, long:Double)
    {
        let boolYapi =  false;
        
        
        let yahooAPI = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text=%22(\(lat),\(long))%22)%20and%20u=%27c%27&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"

        // open weather api
        let openWeatherAPI = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=12328c9427e63313a7434370ed429a08&units=metric"
        
        let stringUrl = boolYapi ? yahooAPI : openWeatherAPI
        
        if let finalUrl = URL(string: stringUrl)
        {
            let urlRequest = URLRequest(url: finalUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60.0);
            let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: /*yahooWeatherReportHandler*/weatherReportHandler)
            task.resume();
        }
    }
    
    
    func yahooWeatherReportHandler(result:Data?, response:URLResponse?, error1:Error?)
    {
        guard error1 == nil else {
            
            return;
        }
        
        if let finalResult = result{
            
            do{
                let resultDetailsOptional = try JSONSerialization.jsonObject(with: finalResult, options: .mutableContainers) as? [String:AnyObject]
                
                if let resultDetails = resultDetailsOptional, let query = resultDetails["query"], let mainResult = query["results"] as? NSDictionary
                {
                    let temp = mainResult.value(forKeyPath: "channel.item.condition.temp") as! String
                    let type = mainResult.value(forKeyPath: "channel.item.condition.text") as! String
                    let cityTitle = mainResult.value(forKeyPath: "channel.location.city") as! String
                    let countrYitle = mainResult.value(forKeyPath: "channel.location.country") as! String
                    let regionTitle = mainResult.value(forKeyPath: "channel.location.region") as! String
                    
                    let finalTitle = "Weather for \n"+cityTitle+", "+regionTitle+", "+countrYitle;
                    
                    self.gUserDefault.set(String(temp), forKey: kValue);
                    self.gUserDefault.set(type, forKey: kType);
                    self.gUserDefault.set(finalTitle, forKey: kLName);
                    self.gUserDefault.synchronize();
                    
                    OperationQueue.main.addOperation {
                        self.lblTemp.text = self.tempFormatValue(strTemp: String(temp))
                        self.lblLocationName.text = finalTitle
                        self.lblType.text = type;
                    }
                }
                else{
                    
                    OperationQueue.main.addOperation {
                        
                        self.lblTemp.text = ""
                        self.lblLocationName.text = "No Results for your location area!"
                        self.lblType.text = "";
                    }
                }
            }
            catch{
                
            }
        }
    }
    func weatherReportHandler(result:Data?, response:URLResponse?, error1:Error?)
    {
        guard error1 == nil else {
            
            return;
        }
        
        if let finalResult = result{
            
            do{
                let resultDetailsOptional = try JSONSerialization.jsonObject(with: finalResult, options: .mutableContainers) as? [String:AnyObject]
                
                if let resultDetails = resultDetailsOptional
                {
                    let tempratureC = resultDetails["main"]?["temp"] as! Double
                    let arrType = resultDetails["weather"] as! [[String:AnyObject]]
                    let type = arrType[0]["description"] as! String
                    
                    self.gUserDefault.set(type, forKey: kType);

//                    NSLog("weather: %f", tempratureC)
                    let strValue = String(format: "%0.0f", tempratureC);
                    self.gUserDefault.set(strValue, forKey: kValue);
                    self.gUserDefault.synchronize();
//                    print("update temperature ui.");
                    
                    
                    OperationQueue.main.addOperation {
                        self.lblTemp.text = self.tempFormatValue(strTemp: strValue);
                        self.lblType.text = type;
                    }
                    
//                    self.lblTemp.performSelector(onMainThread: #selector(setter: UILabel.text), with: tempFormatValue(strTemp: strValue), waitUntilDone: false);
                }
                
            }catch{
                
            }
            
        }
    }
    
}
