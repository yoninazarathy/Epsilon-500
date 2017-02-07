//
//  SettingsTableViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 27/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBAction func settingsSwitchChange(_ sender: UISwitch) {
        if allowsAdminMode{
            (UIApplication.shared.delegate as! AppDelegate).setInAdminMode(sender.isOn)
            let alert = UIAlertController(title: "One on Epsilon Development", message: "You are \(isInAdminMode ? "entering" : "leaving") manage mode", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                if isInAdminMode{
                    (UIApplication.shared.delegate as! AppDelegate).loadAdmin()
                }else{
                    (UIApplication.shared.delegate as! AppDelegate).loadClient()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //QQQQ this is bad as it is linked to a reusable cell
    @IBOutlet weak var settingsSwitch: UISwitch!
    
    //QQQQ this is bad as it is linked to a reusable cell
    @IBAction func buttonCellClick(_ sender: UIButton) {
        print("click...")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if allowsAdminMode{
            settingsSwitch.isOn = isInAdminMode
        }
        
        
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = nil
        switch indexPath.row{
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellSwitch", for: indexPath)
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellButton", for: indexPath)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "settingsCellSwitch", for: indexPath)
        default:
            break
        }
        return cell
    }
    

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
