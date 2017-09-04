//
//  TermListViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 30/5/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

//https://stackoverflow.com/questions/38435308/swift-get-lighter-and-darker-color-variations-for-a-given-uicolor
extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

class TermListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var hashTagsToShow: [String] = []
    
    var curator: String = "All"
    var reviewer: String = "All"
    
    @IBOutlet var curatorStack: UIStackView!
    @IBOutlet var reviewerStack: UIStackView!
    @IBOutlet var termListText: UITextField!
    
    @IBOutlet var termType: UISegmentedControl!
    
    @IBOutlet var termTable: UITableView!
    
    let editorOptions: [String] = ["All","None","Coco","Inna","Phil","Yoni","Yousuf"]
    
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
        for ht in EpsilonStreamDataModel.fullHashTagList{
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
        hashTagsToShow.sort()
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
        cell.isUserInteractionEnabled = true

        switch termType.selectedSegmentIndex{
        case 0:
            let tag = hashTagsToShow[indexPath.row]
            var numVideos = 0
            if let num = EpsilonStreamDataModel.videosOfHashTag[tag]?.count{
                    numVideos = num
            }
            var numVideosInCollection = 0
            if let num = EpsilonStreamDataModel.videosOfHashTagInColl[tag]?.count{
                numVideosInCollection = num
            }
            var numArticles = 0
            if let num = EpsilonStreamDataModel.articlesOfHashTag[tag]?.count{
                numArticles = num
            }
            var numArticlesInCollection = 0
            if let num = EpsilonStreamDataModel.articlesOfHashTagInColl[tag]?.count{
                numArticlesInCollection = num
            }
            var numGames = 0
            if let num = EpsilonStreamDataModel.gamesOfHashTag[tag]?.count{
                numGames = num
            }
            var numGamesInCollection = 0
            if let num = EpsilonStreamDataModel.gamesOfHashTagInColl[tag]?.count{
                numGamesInCollection = num
            }

            
            
            let totalContent = numVideos + numArticles + numGames
            let totalContentInColl = numVideosInCollection + numArticlesInCollection + numGamesInCollection
            
            let curatorHere = EpsilonStreamDataModel.curatorOfHashTag[tag]!
            let reviewerHere = EpsilonStreamDataModel.reviewerOfHashTag[tag]!
            
            cell.textLabel!.text = "\(tag): \(totalContentInColl,totalContent) (V: \(numVideosInCollection,numVideos), A: \(numArticlesInCollection,numArticles), G: \(numGamesInCollection,numGames)), Curator: \(curatorHere), Reviewer: \(reviewerHere)"
            cell.detailTextLabel!.text = "\(indexPath.row+1)  \(EpsilonStreamDataModel.rawTitleOfHashTag[tag]!)"
            cell.detailTextLabel!.numberOfLines = 1
            cell.sizeToFit()
            
            switch totalContentInColl{
            case 0:
                cell.backgroundColor = UIColor.red.lighter(by: 70)
            case 1..<5:
                cell.backgroundColor = UIColor.orange//.lighter(by: 70)
            case 5..<10:
                cell.backgroundColor = UIColor.yellow.lighter(by: 70)
            default:
                cell.backgroundColor = UIColor.green.lighter(by: 70)
            }
            
            if EpsilonStreamDataModel.hashTagInCollection[tag]! == false{
                cell.backgroundColor = UIColor.purple
            }
            
        case 1:
            let tit = EpsilonStreamDataModel.fullTitles[indexPath.row]
            cell.textLabel!.text = tit
             cell.detailTextLabel!.text = "\(indexPath.row+1)  \(EpsilonStreamDataModel.hashTagOfTitle[tit]!)"
            cell.backgroundColor = UIColor.blue.lighter(by: 70)
        default:
            break//QQQQ
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = hashTagsToShow[indexPath.row]
        
        EpsilonStreamAdminModel.setCurrentMathObject(withMathObject: tag)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EditMathObject") as? EditMathObjectViewController{
            navigationController?.pushViewController(vc, animated: true)
        }
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
