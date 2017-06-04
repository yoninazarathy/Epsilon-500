//
//  ViewController.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 19/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import StoreKit
import YouTubePlayer
import Firebase
import Social

//QQQQ see if time efficient
import Toucan

protocol SearcherUI {
    func refreshSearch()
}


class ClientSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AutoCompleteClientDelegate, SKStoreProductViewControllerDelegate, YouTubePlayerDelegate, SearcherUI{
    
    
    
    @IBAction func supriseButtonAction(_ sender: UIButton) {
        let newText = EpsilonStreamDataModel.surpriseText()
        FIRAnalytics.logEvent(withName: "surprise_button", parameters: nil)//QQQQ add old/new
        searchTextField.text = newText
        refreshSearch()
        self.view.endEditing(true)
    }
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState){
        print("PLAYER STATE in search: \(playerState)")
        switch playerState{
        case YouTubePlayerState.Unstarted:
            break
        case YouTubePlayerState.Ended:
            break
        case YouTubePlayerState.Playing:
            print("playing.... now pause...")
            videoPlayer.pause()
            break
        case YouTubePlayerState.Paused:
            break
        case YouTubePlayerState.Buffering:
            break
        case YouTubePlayerState.Queued:
            break
        }
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView){
        print("player ready")
        //QQQQ doesn't work yet videoPlayer.play()
        videoPlayer.isHidden = true
    }
    
    @IBAction func whyHowChanged(_ sender: UISegmentedControl) {
        refreshSearch()
    }
    
    @IBOutlet weak var whyHowSegmentedControl: UISegmentedControl!
    @IBAction func settingsButtonAction(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "clientSettingsViewController") as? ClientSettingsViewController{
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    let autoCompleteTableDelegate = AutoCompleteTableDelegate()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var ageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var resultsTable: UITableView!
    
    @IBOutlet weak var autoCompleteTable: UITableView!
    
    // delete QQQQ - var playerBank: [YouTubePlayerView] = []
    
    var searchResultItems = [SearchResultItem]()
    
    @IBAction func searchEditChange(_ sender: UITextField) {
        if sender.text! == ""{
            view.sendSubview(toBack: autoCompleteTable)
            autoCompleteTable.isHidden = true
        }else{
            autoCompleteTableDelegate.autoCompleteOptions = EpsilonStreamDataModel.autoCompleteListTitle(sender.text!)
            autoCompleteTable.reloadData()
            if(autoCompleteTableDelegate.autoCompleteOptions.count > 0){
                view.bringSubview(toFront: autoCompleteTable)
                autoCompleteTable.isHidden = false
            }else{
                view.sendSubview(toBack: autoCompleteTable)
                autoCompleteTable.isHidden = true
            }
        }
        refreshSearch()
    }
    
    @IBAction func ageValueChange(_ sender: UISegmentedControl) {
        refreshSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search Epsilon Stream"
        searchTextField.delegate = self
        resultsTable.delegate = self
        resultsTable.dataSource = self
        autoCompleteTable.delegate = autoCompleteTableDelegate
        autoCompleteTable.dataSource = autoCompleteTableDelegate
        autoCompleteTableDelegate.delegate = self
        
        searchTextField.text = ""
        //view.sendSubview(toBack: autoCompleteTable)
        autoCompleteTable.isHidden = true
        
        EpsilonStreamBackgroundFetch.searcherUI = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    
    func selected(_ string: String){
        searchTextField.text = string
        autoCompleteTable.isHidden = true
        refreshSearch()
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshSearch()
    }
    
    var currentSearch = EpsilonStreamSearch()
    
    func refreshSearch(){
        currentSearch.searchString = searchTextField.text!

        switch whyHowSegmentedControl.selectedSegmentIndex{
        case 0:
            currentSearch.whyHow = 0.0
        case 1:
            currentSearch.whyHow = 1.0
        default:
            break//QQQQ
        }
        
        switch ageSegmentedControl.selectedSegmentIndex{
        case 0:
            currentSearch.setAgeWeights(basedOn: 8)
        case 1:
            currentSearch.setAgeWeights(basedOn: 12)
        case 2:
            currentSearch.setAgeWeights(basedOn: 16)
        default:
            break//QQQQ
        }

        //if at top of stack
        //QQQQ implement this - but it requires care to choose what is a search and what isn't
      //  if EpsilonStreamDataModel.searchStackIndex == EpsilonStreamDataModel.searchStack.count{
      //      EpsilonStreamDataModel.searchStack.append(currentSearch)
      //      EpsilonStreamDataModel.searchStackIndex += 1
      //  }else{
      //      EpsilonStreamDataModel.searchStack[EpsilonStreamDataModel.searchStackIndex] = currentSearch
      //      EpsilonStreamDataModel.searchStack.removeSubrange(EpsilonStreamDataModel.searchStackIndex+1..<EpsilonStreamDataModel.searchStack.count)
       // }
        
        searchResultItems = EpsilonStreamDataModel.search(withQuery: currentSearch)

        /*
        //loop on results for prefetching
        for it in searchResultItems{
            switch it.type{
                case SearchResultItemType.video:
                    print("QQQQ - to-do prefetch video")
                case SearchResultItemType.iosApp:
                    break
                    //QQQQ - I don't think appstore can be prefetched...??? Or yes?
                case SearchResultItemType.gameWebPage:
                    let urlString = (it as! GameWebPageSearchResultItem).url
                    _ = WebViewPrefetcher.doWebPage(withURLString: urlString)
                    //QQQQ view.addSubview(wv!)
                    break
                /////////////////////////
                /////////////////////////
                case SearchResultItemType.blogWebPage:
                    let urlString = (it as! BlogWebPageSearchResultItem).url
                    _ = WebViewPrefetcher.doWebPage(withURLString: urlString)
                    //view.addSubview(wv!)
                    //wv!.isHidden = true
                    break
            }
                
            // let playerView = YouTubePlayerView(frame: view.frame)
            // playerView.loadVideoID((it as! VideoSearchResultItem).youtubeId) //QQQQ fix up
            // playerView.delegate = self
            // playerBank.append(playerView)
        }
        
        */
        
        resultsTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        let transition = CATransition()
        transition.type = kCATransitionReveal
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeForwards
        transition.duration = 0.5
        transition.subtype = kCATransitionFromBottom
        resultsTable.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        
        refreshSearch()
        //view.sendSubview(toBack: autoCompleteTable)
        autoCompleteTable.isHidden = true
        return false
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return searchResultItems.count
    }


    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch searchResultItems[indexPath.row].type{
        case SearchResultItemType.video:
            let videoItem = searchResultItems[indexPath.row] as! VideoSearchResultItem

            
            let cell = tableView.dequeueReusableCell(withIdentifier:
                    "searchTableCellVideo", for: indexPath)
                
            let imageView = cell.viewWithTag(1) as! UIImageView
            if let image = searchResultItems[indexPath.row].image{
                imageView.image = image
            }else{
                print("default image")
                imageView.image = UIImage(named: "OneOnEpsilonLogo3")
            }
            
            
            let title = cell.viewWithTag(2) as! UILabel
            title.lineBreakMode = .byWordWrapping
            title.numberOfLines = 0
            title.text = searchResultItems[indexPath.row].title
            
            let channel = cell.viewWithTag(3) as! UILabel
            channel.text = searchResultItems[indexPath.row].channel
            
            
            let viewed = cell.viewWithTag(4) as! UIImageView
            if videoItem.percentWatched == 0.0{
                viewed.image = UIImage(named: "unviewed")
            }else if videoItem.percentWatched == 100.0{
                viewed.image = UIImage(named: "viewedFull")
            }else{
                viewed.image = UIImage(named: "viewedPartial")
            }
            
            //let duration = cell.viewWithTag(5) as! UILabel
            if let dur = videoItem.durationString{
                //duration.text = ""//dur
                channel.text?.append(", \(dur) min")
            }else{
                //duration.text = ""//QQQQ
            }
            
            return cell

        /////////////////////////
        /////////////////////////
        case SearchResultItemType.iosApp:
            let iosAppItem = searchResultItems[indexPath.row] as! IOsAppSearchResultItem

            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellApp", for: indexPath)
            
            let title = cell.viewWithTag(2) as! UILabel
            title.text = "\(iosAppItem.title)   (App Store)"
            
            let org = cell.viewWithTag(3) as! UILabel
            org.text = iosAppItem.channel
            
            let im = cell.viewWithTag(1) as! UIImageView
  
            var img = iosAppItem.image!
            img = Toucan(image: img).resize(CGSize(width: 100, height: 100), fitMode: Toucan.Resize.FitMode.crop).image
            img = Toucan(image: img).maskWithRoundedRect(cornerRadius: 30).image
            im.image = img
            
            return cell
            
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.gameWebPage:
            //QQQQ this isn't implement well yet
            let iosAppItem = searchResultItems[indexPath.row] as! GameWebPageSearchResultItem
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellApp", for: indexPath)
            
            let title = cell.viewWithTag(2) as! UILabel
            title.text = "\(iosAppItem.title)   (Web Page)"
            
            let org = cell.viewWithTag(3) as! UILabel
            org.text = iosAppItem.channel
            
            let im = cell.viewWithTag(1) as! UIImageView
            var img = iosAppItem.image!
            img = Toucan(image: img).resize(CGSize(width: 100, height: 100), fitMode: Toucan.Resize.FitMode.crop).image
            img = Toucan(image: img).maskWithRoundedRect(cornerRadius: 30).image
            im.image = img

            
            return cell
            
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.blogWebPage:
            let blogWebItem = searchResultItems[indexPath.row] as! BlogWebPageSearchResultItem
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellBlog", for: indexPath)
            
            let title = cell.viewWithTag(2) as! UILabel
            title.text = blogWebItem.title
            
            let org = cell.viewWithTag(3) as! UILabel
            org.text = blogWebItem.channel
            
            let im = cell.viewWithTag(1) as! UIImageView
            var img = blogWebItem.image!
            img = Toucan(image: img).resize(CGSize(width: 100, height: 100), fitMode: Toucan.Resize.FitMode.crop).image
            img = Toucan(image: img).maskWithEllipse().image
            im.image = img

            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchResultItems[indexPath.row].type{
        case SearchResultItemType.video:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PlayVideo") as? PlayVideoViewController{
                // QQQQ - delete vc.videoPlayer = playerBank[indexPath.row]
                
                let videoItem = searchResultItems[indexPath.row] as! VideoSearchResultItem
                
                vc.videoIdToPlay = videoItem.youtubeId
                navigationController?.pushViewController(vc, animated: true)
            }

        /////////////////////////
        /////////////////////////
        case SearchResultItemType.iosApp:
            jumpToIosApp(withCode: (searchResultItems[indexPath.row] as! IOsAppSearchResultItem).appId) //QQQQ
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.gameWebPage:
            jumpToWebPage(withURLstring: (searchResultItems[indexPath.row] as! GameWebPageSearchResultItem).url)
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.blogWebPage:
            jumpToWebPage(withURLstring: (searchResultItems[indexPath.row] as! BlogWebPageSearchResultItem).url)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Share"){(action, index) in
            switch self.searchResultItems[index.row].type{
            case SearchResultItemType.video:
                let video = self.searchResultItems[index.row] as! VideoSearchResultItem
                
                let shareString = "Check out this video: https://youtu.be/\(video.youtubeId), shared using Epsilon Stream Beta, https://www.epsilonstream.com."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
                
                
                /*
                 //QQQQ not doing this - delte?
                if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook){
                    vc.setInitialText("I watch this on Epsilon Stream (https:www.epsilonstream.com):")
                    vc.add(URL(string: "https:youtu.be/\(video.youtubeId)"))
                    self.present(vc,animated:true)
                }
                 */

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.iosApp:
                print("need to implement share of ios App.... QQQQ")

            /////////////////////////
            /////////////////////////
            case SearchResultItemType.gameWebPage:
                print("need to implement share of game web page.... QQQQ")

            /////////////////////////
            /////////////////////////
            case SearchResultItemType.blogWebPage:
                let webPage = self.searchResultItems[index.row] as! BlogWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream Beta, https://www.epsilonstream.com."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
            }
            
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }
        share.backgroundColor = .green
        
        
        if allowsAdminMode == false{
            return [share]
        }

        //if got down to here then allowing admin mode
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit"){(action, index) in
            switch self.searchResultItems[index.row].type{
            case SearchResultItemType.video:
    
                isInAdminMode = true
                let youTubeIdToEdit = (self.searchResultItems[index.row] as! VideoSearchResultItem).youtubeId
                (UIApplication.shared.delegate as! AppDelegate).loadAdmin(withVideo: youTubeIdToEdit)
                
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.iosApp:
                print("need to implement edit of blog")
                
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.gameWebPage:
                print("need to implement edit of webpage")
                
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.blogWebPage:
                print("need to implement edit of blog")
            }
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }

        edit.backgroundColor = .red
        
        return [share, edit]
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100 //QQQQ
    }
    
    
    func jumpToIosApp(withCode code:String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        //let codeAsInt = Int(code)
        //let codeAsNSNumber = NSNumber(value:codeAsInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: Int(code)!)]
        
        storeViewController.loadProduct(withParameters: parameters)
            {result, error in
                if result {
                    self.present(storeViewController,
                                 animated: true, completion: nil)
                    print("called: App Store")
                }
            }
    }
    

    func jumpToWebPage(withURLstring string: String){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "webViewingViewController") as? WebViewingViewController{
            vc.webURLString = string
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController){
        print("called: productViewControllerDidFinish()")
        viewController.dismiss(animated: true, completion: nil)
    }
}

