//
//  TermSelectorViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 30/5/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit


class TermSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UITextFieldDelegate{
    @IBOutlet var termTable: UITableView!
    @IBOutlet weak var filterTextField: UITextField!
    
    var hashTagsToShow: [String] = []
    var fullHashTags: [String] = []
    var hashTagsSelected: Set<String> = []
    
    var topLabel = ""
    
    func textFieldDidChange(_ textField: UITextField) {
        updateData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func updateData(){
        EpsilonStreamAdminModel.selectedHashTagList = EpsilonStreamAdminModel.selectedHashTagList.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let htList = EpsilonStreamAdminModel.selectedHashTagList.components(separatedBy: ",")
        for ht in htList{
            if EpsilonStreamDataModel.fullHashTagList.contains(ht) || ht == "#noTag"{
                hashTagsSelected.insert(ht)
            }else{
                //QQQQ not sure what to do
                print("illegal hashTag found: \(ht)")
            }
        }
        
        let pattern = filterTextField.text!.lowercased()
        
        if pattern != ""{
            hashTagsToShow = fullHashTags.filter(){ $0.lowercased().contains(pattern)}
        }else{
            hashTagsToShow = fullHashTags
        }
        
        hashTagsToShow.sort()
        termTable.reloadData()
        
        navigationItem.title = topLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termTable.delegate = self
        termTable.dataSource = self
        filterTextField.delegate = self
        filterTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        termTable.estimatedRowHeight = 144.0 // standard tableViewCell height
        termTable.rowHeight = UITableViewAutomaticDimension
        fullHashTags = EpsilonStreamDataModel.fullHashTagList
        updateData()
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        //EpsilonStreamDataModel.printMathObjects()
    }


    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let cnt = hashTagsToShow.count

        return cnt
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "termListCell", for: indexPath)
        cell.isUserInteractionEnabled = true

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
            cell.detailTextLabel!.text = "\(indexPath.row+1)  \(EpsilonStreamDataModel.rawTitleOfHashTag[tag]!)"
            cell.detailTextLabel!.numberOfLines = 1
            cell.sizeToFit()
            
            switch totalContent{
            case 0:
                cell.backgroundColor = UIColor.red.lighter(by: 70)
            case 1..<9:
                cell.backgroundColor = UIColor.orange.lighter(by: 70)
            case 9..<17:
                cell.backgroundColor = UIColor.yellow.lighter(by: 70)
            default:
                cell.backgroundColor = UIColor.green.lighter(by: 70)
            }

            if hashTagsSelected.contains(tag){
                cell.backgroundColor = UIColor.blue
            }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = hashTagsToShow[indexPath.row]

        if hashTagsSelected.contains(tag){
            hashTagsSelected.remove(tag)
        }else{
            hashTagsSelected.insert(tag)
        }
        
        if hashTagsSelected.count > 1{
            hashTagsSelected.remove("#noTag")
        }else if hashTagsSelected.count == 0{
            hashTagsSelected.insert("#noTag")
        }
        
        var htList = ""
        var count = 0
        for ht in hashTagsSelected{
            if count >= 1{
                htList.append(",")
            }
            htList.append("\(ht)")
            count += 1
        }
        
        EpsilonStreamAdminModel.selectedHashTagList = htList

        updateData()
    }
}
