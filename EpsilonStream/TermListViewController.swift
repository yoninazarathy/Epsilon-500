//
//  TermListViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 30/5/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class TermListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var hashTagsToShow: [String] = []
    
    var curator: String = "All"
    var reviewer: String = "All"
    
    @IBOutlet var curatorStack: UIStackView!
    @IBOutlet var reviewerStack: UIStackView!
    @IBOutlet var termListText: UITextField!
    
    @IBOutlet var termType: UISegmentedControl!
    
    @IBOutlet var termTable: UITableView!
    
    let editorOptions: [String] = ["All","None","Coco","Inna","Yoni","Yousuf"]
    
    @IBAction func curateSegmentChanged(_ sender: UISegmentedControl) {
        curator = editorOptions[sender.selectedSegmentIndex]
        updateData()
    }
    
    @IBAction func reviewSegmentChanged(_ sender: UISegmentedControl) {
        reviewer = editorOptions[sender.selectedSegmentIndex]
        updateData()
    }
    
    func updateData(){
        hashTagsToShow = []
        for ht in EpsilonStreamDataModel.hashTagAutoCompleteList{
            var matchCurate = false
            var matchReview = false
            if curator == "All"{
                matchCurate = true
            }else if let dbCurator = EpsilonStreamDataModel.curatorOfHashTag[ht]{
                if dbCurator == curator{
                    matchCurate = true
                }
            }else{
                print("ERROR with curatorOfHashTag: \(ht) -- \(EpsilonStreamDataModel.curatorOfHashTag[ht])")
            }
            
            if reviewer == "All"{
                matchReview = true
            }else if let dbCurator = EpsilonStreamDataModel.reviewerOfHashTag[ht]{
                if dbCurator == reviewer{
                    matchReview = true
                }
            }else{
                print("ERROR with reviewerOfHashTag: \(ht) -- \(EpsilonStreamDataModel.reviewerOfHashTag[ht])")
            }
            
            if matchCurate && matchReview{
                hashTagsToShow.append(ht)
            }
        }
        termTable.reloadData()
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            curatorStack.isHidden = false
            reviewerStack.isHidden = false
        case 1:
            curatorStack.isHidden = true
            reviewerStack.isHidden = true
        default:
            break
        }
        updateData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        termTable.delegate = self
        termTable.dataSource = self
        
        termTable.estimatedRowHeight = 144.0 // standard tableViewCell height
        termTable.rowHeight = UITableViewAutomaticDimension
        
        updateData()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        //EpsilonStreamDataModel.printMathObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        var cnt = 0
        
        switch termType.selectedSegmentIndex{
        case 0:
            cnt = hashTagsToShow.count
        case 1:
            cnt = EpsilonStreamDataModel.fullTitles.count
        default:
            break//QQQQ
        }

        return cnt
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "termListCell", for: indexPath)
        cell.isUserInteractionEnabled = false

        switch termType.selectedSegmentIndex{
        case 0:
            let tag = hashTagsToShow[indexPath.row]
            var numVideos = 0
            if let num = EpsilonStreamDataModel.videosOfHashTag[tag]?.count{
                    numVideos = num
            }
            var numArticles = 0
            if let num = EpsilonStreamDataModel.articlesOfHashTag[tag]?.count{
                numArticles = num
            }
            var numGames = 0
            if let num = EpsilonStreamDataModel.gamesOfHashTag[tag]?.count{
                numGames = num
            }
            let totalContent = numVideos + numArticles + numGames
            
            let curatorHere = EpsilonStreamDataModel.curatorOfHashTag[tag]!
            let reviewerHere = EpsilonStreamDataModel.reviewerOfHashTag[tag]!
            
            cell.textLabel!.text = "\(tag): (V: \(numVideos), A: \(numArticles), G: \(numGames)), Curator: \(curatorHere), Reviewer: \(reviewerHere)"
            cell.detailTextLabel!.text = "\(indexPath.row+1)  \(EpsilonStreamDataModel.rawTitleOfHashTag[tag])"
            cell.detailTextLabel!.numberOfLines = 1
            cell.sizeToFit()
            
            switch totalContent{
            case 0:
                cell.backgroundColor = UIColor.red
            case 1..<9:
                cell.backgroundColor = UIColor.orange
            case 9..<17:
                cell.backgroundColor = UIColor.yellow
            default:
                cell.backgroundColor = UIColor.green
            }
            
        case 1:
            let tit = EpsilonStreamDataModel.fullTitles[indexPath.row]
            cell.textLabel!.text = tit
             cell.detailTextLabel!.text = "\(indexPath.row+1)  \(EpsilonStreamDataModel.hashTagOfTitle[tit]!)"
            cell.backgroundColor = UIColor.blue
        default:
            break//QQQQ
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
