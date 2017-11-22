//
//  FlickrTableViewController.swift
//  ssomlk_project_2
//
//  Created by Wijekoon Mudiyanselage Shanka Primal Somasiri on 14/11/17.
//  Copyright © 2017 Wijekoon Mudiyanselage Shanka Primal Somasiri. All rights reserved.
//

import UIKit
import CoreData

class FlickrTableViewController: UITableViewController {

    @IBOutlet var tblViewFlikr: UITableView!
    
    //Attribute for the array
    var data = [NSManagedObject]()
    
    //Attribute for the AppDelegate
    var del: AppDelegate!
    
    //Attribute for the context
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        initializaContext()
    }
    
    // Everytime the data is reloaded when the view will appear
    override func viewWillAppear(_ animated: Bool) {
        queryData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Initialize the context for database operations
    func initializaContext(){
        self.del = UIApplication.shared.delegate as! AppDelegate
        self.context = del.persistentContainer.viewContext
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.data.count
    }

    // overide function to create the cell values of the tabel view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! FlickrTableViewCell
        cell.txtTitleFlickr.text = data[indexPath.row].value(forKey: "title") as? String
        cell.txtDescriptionFlickr.text = data[indexPath.row].value(forKey: "descrip") as? String
        let image = data[indexPath.row].value(forKey: "image") as! NSData
        let img = UIImage(data: image as Data)
        cell.imgFlickr.image = img
        
        return cell
    }
    
    //fetch the data from the database and display in the table view
    func queryData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FlickrLibrary")
        
        request.returnsObjectsAsFaults = false;
        
        do {
            let results = try self.context.fetch(request)
            if(results.count > 0){
                self.data = results as! [NSManagedObject]
            }else{
                self.data.removeAll()
            }
        } catch {
            showAlertWindow("ERROR", "Database Error While Fetching Data")
        }
        self.tblViewFlikr.reloadData()
    }
    
    /*
     Seperate function is written in order to display message box when needed. User can pass the title and the message to the function if needed to display a mesage
     */
    func showAlertWindow(_ titelData: String, _ messageData: String){
        let alertWindow = UIAlertController(title: titelData, message: messageData, preferredStyle: .alert)
        alertWindow.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
            alertWindow.dismiss(animated: true, completion: nil)}))
        self.present(alertWindow, animated: true, completion: nil)
    }

}
