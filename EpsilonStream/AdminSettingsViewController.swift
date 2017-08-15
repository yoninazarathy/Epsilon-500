//
//  SettingsTableViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 27/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import CloudKit

class AdminSettingsViewController: UIViewController {
    
    @IBAction func reloadFromCloudAction(_ sender: UIButton) {
        EpsilonStreamBackgroundFetch.runUpdate()
    }
    
    @IBAction func deleteLocalInfoAction(_ sender: Any) {
        //QQQQ put spinner
        
        EpsilonStreamDataModel.deleteAllEntities(withName: "VersionInfo")
        EpsilonStreamDataModel.deleteAllEntities(withName: "Video")
        EpsilonStreamDataModel.deleteAllEntities(withName: "MathObject")
        EpsilonStreamDataModel.deleteAllEntities(withName: "FeaturedURL")
        EpsilonStreamDataModel.deleteAllEntities(withName: "Channel")
        EpsilonStreamDataModel.deleteAllEntities(withName: "ImageThumbnail")
        
        ImageManager.deleteAllImageFiles()
        
        EpsilonStreamDataModel.resetDates()
        
        sleep(2)
        
        refreshDataView()
    }
    
    @IBAction func refreshFromYoutubeAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "One on Epsilon Development", message: "Do you want to pull all known channels from youtube?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Safety Code"
        }
        let textField = alert.textFields![0] as UITextField
        textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            EpsilonStreamAdminModel.refreshVideosFromResources()
        }))
        okAction = alert.actions[0]
        okAction.isEnabled = false
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func updateImagesAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "One on Epsilon Development", message: "Do you want to push all images to cloud?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Safety Code"
        }
        let textField = alert.textFields![0] as UITextField
        textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            EpsilonStreamAdminModel.storeAllImages()
        }))
        okAction = alert.actions[0]
        okAction.isEnabled = false
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func textFieldChange(_ sender: UITextField) {
        if sender.text! == "6955"{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }
    
    var okAction: UIAlertAction! = nil
    
    @IBAction func viewReportButton(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "viewReportViewController") as? ViewReportViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func pushToCloudAction(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "One on Epsilon Development", message: "Do you want to push local db to cloud?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Safety Code"
        }
        let textField = alert.textFields![0] as UITextField
        textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)

        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            EpsilonStreamAdminModel.storeAllVideos()
        }))
        okAction = alert.actions[0]
        okAction.isEnabled = false
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
        }))
        self.present(alert, animated: true, completion: nil)
     }

    @IBAction func refreshImagesFromYoutube(_ sender: UIButton) {
        
        //QQQQ refactor this alert
        let alert = UIAlertController(title: "One on Epsilon Development", message: "Do you want to pull images from youtube?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Safety Code"
        }
        let textField = alert.textFields![0] as UITextField
        textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            ImageManager.refreshAllImagesFromURL()
        }))
        okAction = alert.actions[0]
        okAction.isEnabled = false
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet var versionNumberLabel: UILabel!
    @IBOutlet var numberMathObjectLabel: UILabel!
    @IBOutlet var numberVideosLabel: UILabel!
    @IBOutlet var numberFeaturesLabel: UILabel!
    
    @IBOutlet var numImagesFilesLabel: UILabel!
    
    @IBOutlet var textViewOutlet: UITextView!
    

    func refreshDataView(){
        versionNumberLabel.text = "version: \(EpsilonStreamDataModel.latestVersion())"
        numberMathObjectLabel.text = "numMathObjects: \(EpsilonStreamDataModel.numMathObjects()) "
        numberVideosLabel.text = "numVideos: \(EpsilonStreamDataModel.numVideos())"
        numberFeaturesLabel.text = "numFeatures: \(EpsilonStreamDataModel.numFeaturedURLs())"
        numImagesFilesLabel.text = "numImages: CD: \(ImageManager.numImagesInCoreData()), F: \(ImageManager.numImagesOnFile()), B: \(ImageManager.numImagesInBundle())"
    }

    var isInScreen = true

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isInScreen = false
        AppUtility.lockOrientation(.all)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
        refreshDataView()
        
        isInScreen = true
        
        //QQQQ more and more of these tasks born on every visit
        DispatchQueue.global(qos: .userInteractive).async {
            while(self.isInScreen){
                DispatchQueue.main.sync {
                    //print("refresh view")
                    self.refreshDataView()
                }
                sleep(1)
            }
        }
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
