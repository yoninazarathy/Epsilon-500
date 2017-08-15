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
//QQQQ will be back import BetterSegmentedControl
import AVFoundation
import SafariServices

//QQQQ see if time efficient
import Toucan


//from here https://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


protocol SearcherUI {
    func refreshSearch()
}




class ClientSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AutoCompleteClientDelegate, SKStoreProductViewControllerDelegate, SFSafariViewControllerDelegate, YouTubePlayerDelegate, SearcherUI{
    
    @IBOutlet weak var autoCompleteTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainTopStack: UIStackView!
    @IBOutlet weak var mainSegmentView: UIView!
    
    @IBAction func surpriseTouchDown(_ sender: UIButton) {
        sender.imageView?.image = UIImage(named: "Surprise_Icon_Active")
        //QQQQ this doesn't work
    }
    
    var audioPlayer: AVAudioPlayer!
    
    @IBAction func supriseButtonAction(_ sender: UIButton) {
        
        let url = ClientSearchViewController.getSoundURL()
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = 0.15
            audioPlayer.play()
        }catch{
            print("error playing sound")
        }

        autoCompleteTable.isHidden = true

        
        
        let newText = EpsilonStreamDataModel.surpriseText()
        FIRAnalytics.logEvent(withName: "surprise_button", parameters: ["newText" : newText as NSObject])
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
        let searchString = sender.text!.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        
        let firstChar = searchString.characters.first

        
        if searchString == ""{
            autoCompleteTableDelegate.autoCompleteOptions = []
        }else if firstChar == "#"{
            autoCompleteTableDelegate.autoCompleteOptions = EpsilonStreamDataModel.autoCompleteListHashTags(searchString)
        }else if firstChar == "." && isInAdminMode{
            autoCompleteTableDelegate.autoCompleteOptions = EpsilonStreamDataModel.autoCompleteListCommands(searchString)
        }else{
            autoCompleteTableDelegate.autoCompleteOptions = EpsilonStreamDataModel.autoCompleteListTitle(searchString)
        }
        autoCompleteTable.reloadData()
        print(autoCompleteTableDelegate.autoCompleteOptions.count)
        if(autoCompleteTableDelegate.autoCompleteOptions.count > 0){
            view.bringSubview(toFront: autoCompleteTable)
            autoCompleteTable.isHidden = false
            //let activeHeight = autoCompleteTable.rowHeight * CGFloat(autoCompleteTable.numberOfRows(inSection: 0))
            let frm = autoCompleteTable.frame
            autoCompleteTableViewHeightConstraint.constant = self.view.frame.height - keyboardHeight - frm.origin.y
            autoCompleteTable.layoutIfNeeded()

        }else{
            view.sendSubview(toBack: autoCompleteTable)
            autoCompleteTable.isHidden = true
        }
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
        
        resultsTable.separatorStyle = .none
        resultsTable.keyboardDismissMode = .onDrag
        
        
        searchTextField.text = ""
        //view.sendSubview(toBack: autoCompleteTable)
        autoCompleteTable.isHidden = true
        autoCompleteTable.separatorStyle = .none
        
        EpsilonStreamBackgroundFetch.searcherUI = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        view.backgroundColor = UIColor(rgb: ES_watch1)
        view.alpha = 1.0
        
        //        mainTopStack.removeArrangedSubview(mainSegmentView)
        //        mainSegmentView.removeFromSuperview()
        /*
        let viewForSegment = mainSegmentView.viewWithTag(1)!
        
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 0, width: viewForSegment.bounds.width, height: viewForSegment.bounds.height),
            titles: ["Understand Why", "Explore How"],
            index: 1,
            backgroundColor: UIColor(rgb: ES_watch2),
            titleColor: UIColor(rgb: ES_watch3),
            indicatorViewBackgroundColor: .white,
            selectedTitleColor: UIColor(rgb: ES_watch1))
        control.cornerRadius = control.frame.height/2
        control.titleFont = UIFont(name: "HelveticaNeue", size: 14.0)!
        control.selectedTitleFont = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        control.addTarget(self, action: #selector(bscValueChanged(_:)), for: .valueChanged)
        viewForSegment.addSubview(control)
        //viewForSegment.removeFromSuperview()
     */
        refreshSearch()
    }
    
 //   var whyVsHow = 0
   /*
    // MARK: - Action handlers
    func bscValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            whyVsHow = 0
        }
        else {
            whyVsHow = 1
        }
        refreshSearch()
    }
    */
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)

    }
    
    var keyboardHeight = CGFloat(313.0)
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        //AppUtility.lockOrientation(.all)
    }
    
    
    func selected(_ string: String){
        searchTextField.text = string
        autoCompleteTable.isHidden = true
        refreshSearch()
        self.view.endEditing(true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        refreshSearch()
    }
    
    var currentSearch = EpsilonStreamSearch()
    
    func refreshSearch(){
        currentSearch.searchString = searchTextField.text!

        currentSearch.whyHow = 0.5
  /*      switch whyVsHow{ //QQQQ maybe switched???
        case 0:
            currentSearch.whyHow = 0.0
        case 1:
            currentSearch.whyHow = 1.0
        default:
            break//QQQQ
        }
    */
        /*
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
         */
        currentSearch.setAgeWeights(basedOn: 14)

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
        let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
        resultsTable.scrollToRow(at: top as IndexPath, at: .top, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        /*
        let transition = CATransition()
        transition.type = kCATransitionReveal
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeForwards
        transition.duration = 0.5
        transition.subtype = kCATransitionFromBottom
        resultsTable.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        */
        refreshSearch()
        //view.sendSubview(toBack: autoCompleteTable)
        autoCompleteTable.isHidden = true
        return false
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        //QQQQ this is a horrible hack - make cleaner
        if searchResultItems.count == 1 && searchResultItems[0].type == SearchResultItemType.mathObjectLink{
            return 2
        }else{
            return searchResultItems.count
        }
    }


    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //QQQQ rough code in case of no search
        if searchResultItems.count == 1 && searchResultItems[0].type == SearchResultItemType.mathObjectLink{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellSpecialItem", for: indexPath) as! SpecialItemTableViewCell
                cell.mainLabel.text = "No match for \"\(currentSearch.searchString)\""
                cell.clientSearchViewController = self
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellMathObjectLink", for: indexPath) as! MathObjectLinkItemTableViewCell
                cell.configureWith(mathObjectLinkSearchResult: searchResultItems[0] as! MathObjectLinkSearchResultItem)
                return cell
            }
        }
        
        switch searchResultItems[indexPath.row].type{
        case SearchResultItemType.video:
            let cell = tableView.dequeueReusableCell(withIdentifier:
                    "searchTableCellVideo", for: indexPath) as! VideoItemTableViewCell
            cell.configureWith(videoSearchResult:  searchResultItems[indexPath.row] as! VideoSearchResultItem)
            return cell
        case SearchResultItemType.iosApp:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellApp", for: indexPath) as! GameItemTableViewCell
            cell.configureWith(iosAppSearchResult: searchResultItems[indexPath.row] as! IOsAppSearchResultItem)
            return cell
        case SearchResultItemType.gameWebPage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellApp", for: indexPath) as! GameItemTableViewCell
            cell.configureWith(gameWebSearchResult: searchResultItems[indexPath.row] as! GameWebPageSearchResultItem)
            return cell
        case SearchResultItemType.blogWebPage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellBlog", for: indexPath) as! ArticleItemTableViewCell
            cell.configureWith(articleSearchResult: searchResultItems[indexPath.row] as! BlogWebPageSearchResultItem)
            return cell
        case SearchResultItemType.mathObjectLink:
            //QQQQ implement Math ObjectLink Search Result Item
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellMathObjectLink", for: indexPath) as! MathObjectLinkItemTableViewCell
            cell.configureWith(mathObjectLinkSearchResult: searchResultItems[indexPath.row] as! MathObjectLinkSearchResultItem)
            return cell
        case SearchResultItemType.specialItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellSpecialItem", for: indexPath) as! SpecialItemTableViewCell
            cell.configureWith(specialSearchResultItem: searchResultItems[indexPath.row] as! SpecialSearchResultItem)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //QQQQ rough code in case of no search
        if searchResultItems.count == 1{
            if indexPath.row == 0{
                print("select 0")
            }else{
                selected("")
            }
            return
        }

        
        
        switch searchResultItems[indexPath.row].type{
        case SearchResultItemType.video:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PlayVideo") as? PlayVideoViewController{
                // QQQQ - delete vc.videoPlayer = playerBank[indexPath.row]
                vc.isExplodingDots = false //QQQQ read type of video display here
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
            jumpToWebPage(withURLstring: (searchResultItems[indexPath.row] as! GameWebPageSearchResultItem).url, withSplashKey: "gameQQQQ")
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.blogWebPage:
            jumpToWebPage(withURLstring: (searchResultItems[indexPath.row] as! BlogWebPageSearchResultItem).url,inSafariMode: (searchResultItems[indexPath.row]as! BlogWebPageSearchResultItem).isExternal, withSplashKey: searchResultItems[indexPath.row].splashKey)
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.mathObjectLink:
            //QQQQ implement math object link search result item
            let molItem = searchResultItems[indexPath.row] as! MathObjectLinkSearchResultItem
            
            var imageView: UIImageView? = nil
            //QQQQ move elsewhere and allow other splashes.
            if molItem.splashKey == "gmp-splash"{
                imageView = UIImageView(image: UIImage(named: "ed_background1"))
                imageView!.contentMode = .scaleAspectFill
            }else if molItem.splashKey == "youtube-splash"{
                imageView = UIImageView(image: UIImage(named: "youTubeSplash"))
                imageView!.contentMode = .scaleAspectFill
            }else if molItem.splashKey == "OoE-splash"{
                imageView = UIImageView(image: UIImage(named: "oneOnEpsilonSplash"))
                imageView!.contentMode = .scaleAspectFill
            }
        
            if let iv = imageView{
                let window = UIApplication.shared.keyWindow!
                iv.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
                window.addSubview(iv)
                UIView.animate(withDuration: 1.5, animations: {
                    iv.alpha = 0.0
                }, completion:
                    {_ in iv.removeFromSuperview()})
            }
            
            selected(molItem.searchTitle)
            
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.specialItem:
            print("speicalItem click")
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
                let iosApp = self.searchResultItems[index.row] as! IOsAppSearchResultItem
                
                let shareString = "Check this out: https://itunes.apple.com/us/app/id\(iosApp.appId), shared using Epsilon Stream Beta, https://www.epsilonstream.com."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.gameWebPage:
                let webPage = self.searchResultItems[index.row] as! GameWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream Beta, https://www.epsilonstream.com."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.blogWebPage:
                let webPage = self.searchResultItems[index.row] as! BlogWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream Beta, https://www.epsilonstream.com."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.mathObjectLink:
                //QQQQ do something 
                print("not implemented yet")
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.specialItem:
                //QQQQ do something
                print("not implemented yet")

            }
            
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }
        share.backgroundColor = .green
        
        
        if isInAdminMode == false{
            return [share]
        }

        //if got down to here then allowing admin mode
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit"){(action, index) in
            switch self.searchResultItems[index.row].type{
            case SearchResultItemType.video:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let youTubeIdToEdit = (self.searchResultItems[index.row] as! VideoSearchResultItem).youtubeId
                EpsilonStreamAdminModel.setCurrentVideo(withVideo: youTubeIdToEdit)

                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "curateItemViewController") as? CurateItemViewController{
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.iosApp, SearchResultItemType.gameWebPage, SearchResultItemType.blogWebPage:
                let ourFeaturedURLHashtag = (self.searchResultItems[index.row] as! FeatureSearchResultItem).ourFeaturedURLHashtag
                EpsilonStreamAdminModel.setCurrentFeature(withFeature: ourFeaturedURLHashtag)
                
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "curateArticleViewController") as? CurateArticleViewController{
                    self.navigationController?.pushViewController(vc, animated: true)
                }

                
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.mathObjectLink:
                print("need to implement edit of math object link")
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.specialItem:
                print("need to implement edit (or not)")

                
            }
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }

        edit.backgroundColor = .red
        
        //if got down to here then allowing admin mode
        
        let pushDown = UITableViewRowAction(style: .normal, title: "Down"){(action, index) in
            switch self.searchResultItems[index.row].type{
            case SearchResultItemType.video:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let youTubeIdToPushDown = (self.searchResultItems[index.row] as! VideoSearchResultItem).youtubeId
                EpsilonStreamAdminModel.setCurrentVideo(withVideo: youTubeIdToPushDown)
                let newPriority = (self.searchResultItems[index.row+1].foundPriority + self.searchResultItems[index.row + 2].foundPriority)/2
                print(newPriority)
                EpsilonStreamAdminModel.currentVideo.hashTagPriorities = "#homePage\(newPriority)"
                print("push down")
               
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.iosApp, SearchResultItemType.gameWebPage, SearchResultItemType.blogWebPage:
                print("need to handle")
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.mathObjectLink:
                print("need to handle")
                /////////////////////////
            /////////////////////////
            case SearchResultItemType.specialItem:
                print("need to handle")
                
            }
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }
        
        pushDown.backgroundColor = .orange

        
        return [share, edit, pushDown]
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 125 //QQQQ
    }
    
    
    func jumpToIosApp(withCode code:String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        //let codeAsInt = Int(code)
        //let codeAsNSNumber = NSNumber(value:codeAsInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: Int(code)!)]
        
        let window = UIApplication.shared.keyWindow!
        let imageView = UIImageView(image: UIImage(named: "Screen_About_Play"))
        imageView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        window.addSubview(imageView)
        UIView.animate(withDuration: 2.0, animations: {
            imageView.alpha = 0.2
        }, completion:
            {_ in })

        storeViewController.modalTransitionStyle = .crossDissolve
        storeViewController.loadProduct(withParameters: parameters)
            {result, error in
                if result {
                    self.present(storeViewController,
                                 animated: false, completion: {
                                    print("here")
                                    imageView.removeFromSuperview()})
                    print("called: App Store")
                }
            }
    }
    

    func jumpToWebPage(withURLstring string: String, inSafariMode safariMode: Bool = false,withSplashKey splashKey: String = ""){
        if safariMode{
            let alert = UIAlertController(title: "You are leaving Epsilon Stream to an external page", message: "In version 1.0 you can password protect this (not yet in this version).", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                print("OK")
                let safariVC = SFSafariViewController(url: NSURL(string: string) as! URL)
                self.present(safariVC, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
                print("Cancel")
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "webViewingViewController") as? WebViewingViewController{
                vc.webURLString = string
                vc.splashKey = splashKey
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController){
        print("called: productViewControllerDidFinish()")
        viewController.dismiss(animated: true, completion: nil)
    }
    
    class func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getSoundURL()->URL{
        let resourcePath = Bundle.main.resourcePath
        let url = URL(fileURLWithPath:resourcePath!).appendingPathComponent("click.wav")
        return url
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        print("safariViewControllerDidFinish")
        controller.dismiss(animated: true, completion: nil)
    }
    
}

