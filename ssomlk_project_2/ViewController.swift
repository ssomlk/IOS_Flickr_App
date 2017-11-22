//
//  ViewController.swift
//  ssomlk_project_2
//
//  Created by Wijekoon Mudiyanselage Shanka Primal Somasiri on 13/11/17.
//  Copyright © 2017 Wijekoon Mudiyanselage Shanka Primal Somasiri. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var txtKeyWord: UITextField!
    @IBOutlet weak var txtLongitute: UITextField!
    @IBOutlet weak var txtLatitude: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var imgFlickrImage: UIImageView!
    
    var requestURLString : URL!
    
    // define context and delegate variable
    var del: AppDelegate!
    var context: NSManagedObjectContext!
    
    //Identify the imageState (whether a new image is selected by the user or not)
    var imageSelected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Initialize the AppDelegate and the context for Database operations
    func initializeContext(){
        self.del = UIApplication.shared.delegate as! AppDelegate
        self.context = del.persistentContainer.viewContext
    }

    //Search by the Keyword
    @IBAction func searchByKeyword(_ sender: UIButton) {
        validateInput(temp: 1)
    }

    //Search By Longitude and Latitude
    @IBAction func searchByCoordinates(_ sender: UIButton) {
        validateInput(temp: 2)
    }
    
    //Saving button functionality
    @IBAction func saveButtonClick(_ sender: UIButton) {
        validateInput(temp: 3)
    }
    
    // use guard conditions to validate the input by the user
    func validateInput(temp:Int){
        if(temp == 1){
            guard let keyword = self.txtKeyWord.text , keyword != "" else {
                showAlertWindow("VALIDATION ERROR","Keyword cannot be empty")
                return
            }
            self.requestURLString = createURLRequest(searchType:1, longitude:0, latitude:0)
            getDataFromFlickrApi(urlname: self.requestURLString)
        }
        else if (temp == 2){
            guard let longitude = self.txtLongitute.text, let latitude = self.txtLatitude.text , longitude != "", latitude != "" else {
                showAlertWindow("VALIDATION ERROR","Longitude or Latitude cannot be empty")
                return
            }
            
            guard let dlongitude = Double(self.txtLongitute.text!), let dlatitude = Double(self.txtLatitude.text!) else {
                showAlertWindow("VALIDATION ERROR","Longitude and Latitude must be numeric values")
                return
            }
            
            let longRange = validateRange(typeValue: 1, value: dlongitude)
            if(!longRange){
                showAlertWindow("VALIDATION ERROR","Longitude range should be within -180 to 180")
                return
            }
            
            let latRange = validateRange(typeValue: 2, value: dlatitude)
            if(!latRange){
                showAlertWindow("VALIDATION ERROR","Latitude range should be within -90 to 90")
                return
            }
            self.requestURLString = createURLRequest(searchType: 2, longitude: dlongitude, latitude:dlatitude)
            getDataFromFlickrApi(urlname: self.requestURLString)
        }
        else{
            guard let titleValue = self.txtTitle.text, let descValue = self.txtDescription.text, titleValue != "", descValue != "", self.imageSelected == 1 else {
                showAlertWindow("VALIDATION ERROR","Title, Description and Image cannot be empty")
                return
            }
            saveToDatabase()
        }
        
    }
    
    // function to call to show Alerts to the customer
    func showAlertWindow(_ titelData: String, _ messageData: String){
        let alertWindow = UIAlertController(title: titelData, message: messageData, preferredStyle: .alert)
        alertWindow.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            alertWindow.dismiss(animated: true, completion: nil)}))
        self.present(alertWindow, animated: true, completion: nil)
    }
    
    // function to validate the longitude and latitude range
    func validateRange(typeValue: Int, value: Double) -> Bool {
        switch typeValue {
        case 1:
            if(value <= 180 && value >= -180){
                return true
            }
            return false
        case 2:
            if(value <= 90 && value >= -90){
                return true
            }
            return false
        default:
            return false
        }
    }
    
    /*
     This function creates a URL for flicker.photos.search
     Used URLComponents class to create the URL and have appended the query items using URLQueryItem class
     */
    func createURLRequest(searchType: Int, longitude: Double, latitude: Double) -> URL {
        var searchOption: URLQueryItem
        
        var newURLComponent = URLComponents()
        newURLComponent.scheme = "https"
        newURLComponent.host = "api.flickr.com"
        newURLComponent.path = "/services/rest/"
        
        let queryItemQuery1 = URLQueryItem(name: "method", value: "flickr.photos.search")
        let queryItemQuery2 = URLQueryItem(name: "api_key", value: "4731164fb1fa8d70ba2d8224919ae73f")
        let queryItemQuery3 = URLQueryItem(name: "safe_search", value: "1")
        let queryItemQuery4 = URLQueryItem(name: "extras", value: "url_m")
        let queryItemQuery5 = URLQueryItem(name: "format", value: "json")
        let queryItemQuery6 = URLQueryItem(name: "nojsoncallback", value: "1")
        
        if(searchType == 1){
            searchOption = URLQueryItem(name: "text", value: "\(self.txtKeyWord.text!)")
        }else{
            let bboxParams = generateBbox(long:longitude, lat: latitude)
            print(bboxParams)
            searchOption = URLQueryItem(name: "bbox", value: "\(bboxParams)")
        }
        
        newURLComponent.queryItems = [queryItemQuery1, queryItemQuery2, queryItemQuery3,queryItemQuery4, queryItemQuery5, queryItemQuery6,searchOption]
        
        print(newURLComponent.url!)
        
        return newURLComponent.url!
    }
    
    //function which generates the bbox parameters of the flickr api
    func generateBbox(long: Double, lat: Double) -> String{
        let minLong = max((long - 1), -180)
        let maxLong = min((long + 1), 180)
        let minLat = max((lat - 1), -90)
        let maxLat = min((lat + 1), 90)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
    
    //function which runs to create a background task to perform URL request to flickr api to fetch images asynchronously
    func getDataFromFlickrApi(urlname: URL){
        
        let request = URLRequest(url: urlname)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:
        {
            (data, response,error) in
            if(error == nil){
                let jsonData = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                
                let photos = jsonData["photos"] as! [String:AnyObject]
                let libraryphotos = photos["photo"] as! [[String:AnyObject]]
                
                if(libraryphotos.count == 0){
                    DispatchQueue.main.async {
                        self.showAlertWindow("FLICKR ERROR", "No data found...")
                    }
                }else{
                    let random = Int(arc4random_uniform(UInt32(libraryphotos.count)))
                    let randomUrl = libraryphotos[random]["url_m"] as! String
                    
                    print(randomUrl)
                    
                    let imgURL = URL(string: randomUrl)
                    
                    DispatchQueue.main.async {
                        let imageData = try! Data(contentsOf: imgURL!)
                        let image = UIImage(data: imageData)
                        self.imgFlickrImage.image = image
                        self.imageSelected = 1
                    }
                }
            }else{
                print("\(error)")
            }
        })
        task.resume()
    }
    
    // data saving to the database is handled bu function saveToDatabase()
    func saveToDatabase() {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "FlickrLibrary", into: self.context)
        
        entity.setValue(self.txtTitle.text, forKey: "title")
        entity.setValue(self.txtDescription.text, forKey: "descrip")
        
        let image = UIImageJPEGRepresentation(self.imgFlickrImage.image!, 1)
        entity.setValue(image, forKey: "image")
        
        do {
            try context.save()
            showAlertWindow("SUCCESS","Data Saved Successfully")
        } catch {
            showAlertWindow("ERROR","Error Saving Data to Database")
        }
        clearFields()
    }
    
    // clear the fields back to defaults once an item is saved to the database
    func clearFields(){
        self.txtKeyWord.text = ""
        self.txtTitle.text = ""
        self.txtDescription.text = ""
        self.imgFlickrImage.image = UIImage(named: "add-2935429_640")
        self.txtLongitute.text = ""
        self.txtLatitude.text = ""
        self.imageSelected = 0
    }


}

