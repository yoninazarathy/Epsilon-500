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



//https://stackoverflow.com/questions/27761557/shuffling-a-string-in-swift
extension Array {
    var shuffled: Array {
        var array = self
        indices.dropLast().forEach {
            guard case let index = Int(arc4random_uniform(UInt32(count - $0))) + $0, index != $0 else { return }
            swap(&array[$0], &array[index])
        }
        return array
    }
    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
}
extension String {
    var jumble: String {
        return String(Array(characters).shuffled)
    }
}


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




class ClientSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AutoCompleteClientDelegate,
SKStoreProductViewControllerDelegate, SFSafariViewControllerDelegate, YouTubePlayerDelegate, SearcherUI,ImageLoadedDelegate{
    
    var coverImageView: UIImageView! = nil
    
    @IBOutlet weak var autoCompleteTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTopStack: UIStackView!
    @IBOutlet weak var mainSegmentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBAction func homeButtonAction(_ sender: Any) {
        UserMessageManager.userDidAnotherAction()

        if let prevText = searchTextField.text{
            FIRAnalytics.logEvent(withName: "home_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            FIRAnalytics.logEvent(withName: "home_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        searchTextField.text = "" //QQQQ or home?
        BrowseStackManager.reset(withBaseSearch: EpsilonStreamSearch())
        refreshSearch()
        showXButton = false
        //QQQQ duplicated
        surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
    }
    
    @IBAction func searchFieldEditBegin(_ sender: Any) {
        if searchTextField.text! != ""{
            showXButton = true
            surpriseButton.setImage(UIImage(named: "Errase_Icon_Small_Active"), for: .normal)
        }
    }
    
    func clearButtonAction() {
        UserMessageManager.userDidAnotherAction()
        
        if let prevText = searchTextField.text{
            FIRAnalytics.logEvent(withName: "clear_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            FIRAnalytics.logEvent(withName: "clear_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        searchTextField.text = "" //QQQQ or home?
        refreshSearch()
        showXButton = false
        //QQQQ duplicated
            surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
    }

    
    @IBAction func backButtonAction(_ sender: UIButton) {
        UserMessageManager.userDidAnotherAction()

        if let prevText = searchTextField.text{
            FIRAnalytics.logEvent(withName: "back_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            FIRAnalytics.logEvent(withName: "back_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        
        let newSearchText = BrowseStackManager.moveBack().searchString
        print(newSearchText)
        searchTextField.text = newSearchText
        refreshSearch()
    }
    
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        UserMessageManager.userDidAnotherAction()
        if let prevText = searchTextField.text{
            FIRAnalytics.logEvent(withName: "forward_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            FIRAnalytics.logEvent(withName: "forward_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        searchTextField.text = BrowseStackManager.moveForward().searchString
        refreshSearch()
    }
    
    var textShuffleTimer: Timer! = nil
    
    var showXButton = false
    
    @IBAction func supriseButtonAction(_ sender: UIButton) {
        UserMessageManager.userDidAnotherAction()
        
        if showXButton{
            clearButtonAction()
        }else{
            surpriseButton.isEnabled = false
            surpriseButton.imageView!.startAnimating()
            let newText = EpsilonStreamDataModel.surpriseText()
            searchTextField.text = newText.lowercased().jumble
            textShuffleTimer = Timer.every(0.1.seconds) {
                self.searchTextField.text = newText.lowercased().jumble
            }

            Timer.after(0.6, {
                self.surpriseButton.imageView!.stopAnimating()
                self.surpriseButton.imageView!.isHighlighted = false
                FIRAnalytics.logEvent(withName: "surprise_button", parameters: ["newText" : newText as NSObject])
                self.selected(newText)
                if let textShuffleTimer = self.textShuffleTimer {
                    textShuffleTimer.invalidate()
                }
                self.surpriseButton.isEnabled = true
            })
            let url = ClientSearchViewController.getSoundURL()
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.volume = 0.15
                audioPlayer.play()
            }catch{
                print("error playing sound")
            }
        }
        autoCompleteTable.isHidden = true
    }
    
  
    @IBOutlet weak var whyHowSegmentedControl: UISegmentedControl!
    @IBAction func settingsButtonAction(_ sender: UIButton) {
        // IK: Replaced with segue in storyboard.
//        if let vc = storyboard?.instantiateViewController(withIdentifier: "clientSettingsViewController") as? ClientSettingsViewController{
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    let autoCompleteTableDelegate = AutoCompleteTableDelegate()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var ageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var autoCompleteTable: UITableView!
    
    // delete QQQQ - var playerBank: [YouTubePlayerView] = []
    
    var searchResultItems = [SearchResultItem]()
    
    @IBAction func searchEditChange(_ sender: UITextField) {
        UserMessageManager.userDidKeyInAction()
        let searchString = sender.text!.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //QQQQ duplicated
        if searchString == ""{
            showXButton = false
            surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
        }else{
            showXButton = true
            surpriseButton.setImage(UIImage(named: "Errase_Icon_Small_Active"), for: .normal)
        }
        
        let firstChar = searchString.first

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
    
    func imagesUpdate(){
        resultsTable.reloadData()
    }
    
    var surpriseButton: UIButton! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ImageManager.imageLoadedDelegate = self
        
        title = "Search Epsilon Stream"
        searchTextField.delegate = self
        resultsTable.delegate = self
        resultsTable.dataSource = self
        resultsTable.separatorStyle = .none
        resultsTable.keyboardDismissMode = .onDrag

        autoCompleteTable.delegate = autoCompleteTableDelegate
        autoCompleteTable.dataSource = autoCompleteTableDelegate
        autoCompleteTableDelegate.delegate = self
        
        
        surpriseButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
        surpriseButton.imageView!.animationImages = [UIImage(named: "Surprise4")!, UIImage(named: "Surprise1")!, UIImage(named: "Surprise2")!, UIImage(named: "Surprise5")!, UIImage(named: "Surprise3")!, UIImage(named: "Surprise6")!]
        surpriseButton.imageView!.animationDuration = 0.4
        surpriseButton.addTarget(self, action: #selector(supriseButtonAction), for: .touchUpInside)

        
        searchTextField.rightViewMode = .always
        searchTextField.rightView = surpriseButton
        searchTextField.text = ""
        var search = EpsilonStreamSearch()
        search.searchString = ""

        autoCompleteTable.isHidden = true
        autoCompleteTable.separatorStyle = .none
        
        EpsilonStreamBackgroundFetch.searcherUI = self
      
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
        var search = EpsilonStreamSearch()
        search.searchString = string
        if string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""{//QQQQ user can enter "home"
            BrowseStackManager.pushNew(search: search)
        }
        searchTextField.text = string
        autoCompleteTable.isHidden = true
        refreshSearch()
        self.view.endEditing(true)
        FIRAnalytics.logEvent(withName: "item_selected", parameters: ["string" : string as NSObject])
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        refreshSearch()
    }
    
    var currentSearch = EpsilonStreamSearch()
    
    var goingToTop = true
    
    func refreshSearch(){
        
        if searchTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""{
            homeButton.isEnabled = false
        }else{
            homeButton.isEnabled = true
        }
        
        //QQQQ this is duplicated elsewhere
        if  showXButton{
            surpriseButton.setImage(UIImage(named: "Errase_Icon_Small_Active"), for: .normal)
        }else{
            surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
        }
        
        
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

        if let message = UserMessageManager.showMessage(){
            let item = UserMessageResultItem()
            item.title = message
            item.type = SearchResultItemType.messageItem
            searchResultItems.insert(item, at: 0)
        }
        
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
        
        
        forwardButton.isEnabled = BrowseStackManager.canForward()
        backButton.isEnabled = BrowseStackManager.canBack()
        
        resultsTable.reloadData()
        if goingToTop == true{
            let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
            resultsTable.scrollToRow(at: top as IndexPath, at: .top, animated: false)
        }
        goingToTop = true //QQQ super nasty hack
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        refreshSearch()
        autoCompleteTable.isHidden = true
        return false
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        //QQQQ this is a horrible hack - make cleaner
        if searchResultItems.count == 0{// && searchResultItems[0].type == SearchResultItemType.mathObjectLink{
            return 1
        }else{
            return searchResultItems.count
        }
    }


    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResultItems.count == 0{// && searchResultItems[0].type == SearchResultItemType.mathObjectLink{
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
        case SearchResultItemType.messageItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableCellUserMessage", for: indexPath) as! UserMessageTableViewCell
            cell.configureWith(userMessageResultItem: searchResultItems[indexPath.row] as! UserMessageResultItem)
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //will be if there is no search.
        //QQQQ fix this so it acts better on the "Let our team known"
        if searchResultItems.count == 0{
            if let text = searchTextField.text{
                FIRAnalytics.logEvent(withName: "no_search", parameters: ["stringSearch" : text as NSObject])
            }else{
                FIRAnalytics.logEvent(withName: "no_search", parameters: ["stringSearch" : "EMPTY" as NSObject])
            }
            return
        }
        
        switch searchResultItems[indexPath.row].type{
        case SearchResultItemType.video:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PlayVideo") as? PlayVideoViewController{
                // QQQQ - delete vc.videoPlayer = playerBank[indexPath.row]
                vc.isExplodingDots = false //QQQQ read type of video display here
                let videoItem = searchResultItems[indexPath.row] as! VideoSearchResultItem
                FIRAnalytics.logEvent(withName: "video_play", parameters: ["videoId" : videoItem.youtubeId as NSObject])
                vc.videoIdToPlay = videoItem.youtubeId
                navigationController?.pushViewController(vc, animated: true)
            }

        /////////////////////////
        /////////////////////////
        case SearchResultItemType.iosApp:
            FIRAnalytics.logEvent(withName: "appStore_go", parameters: ["appId" :  (searchResultItems[indexPath.row] as! IOsAppSearchResultItem).appId as NSObject])
            jumpToIosApp(withCode: (searchResultItems[indexPath.row] as! IOsAppSearchResultItem).appId) //QQQQ
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.gameWebPage:
            FIRAnalytics.logEvent(withName: "gameWeb_go", parameters: ["webURL" :  (searchResultItems[indexPath.row] as! GameWebPageSearchResultItem).url as NSObject])
            jumpToWebPage(withURLstring: (searchResultItems[indexPath.row] as! GameWebPageSearchResultItem).url, withSplashKey: "gameQQQQ")
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.blogWebPage:
            FIRAnalytics.logEvent(withName: "web_go", parameters: ["webURL" :  (searchResultItems[indexPath.row] as! BlogWebPageSearchResultItem).url as NSObject])
            jumpToWebPage(withURLstring: (searchResultItems[indexPath.row] as! BlogWebPageSearchResultItem).url,inSafariMode: (searchResultItems[indexPath.row]as! BlogWebPageSearchResultItem).isExternal, withSplashKey: searchResultItems[indexPath.row].splashKey)
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.mathObjectLink:
            //QQQQ implement math object link search result item
            let molItem = searchResultItems[indexPath.row] as! MathObjectLinkSearchResultItem
     
            FIRAnalytics.logEvent(withName: "mathObjectLink_go", parameters: ["link_name" :  molItem.ourMathObjectLinkHashTag as NSObject])
            
            //QQQQ move elsewhere and allow other splashes.
            if molItem.splashKey == "gmp-splash"{
                coverImageView = UIImageView(image: UIImage(named: "ed_background1"))
                coverImageView!.contentMode = .scaleAspectFill
            }else if molItem.splashKey == "youtube-splash"{
                coverImageView = UIImageView(image: UIImage(named: "youTubeSplash"))
                coverImageView!.contentMode = .scaleAspectFill
            }else if molItem.splashKey == "OoE-splash"{
                coverImageView = UIImageView(image: UIImage(named: "oneOnEpsilonSplash"))
                coverImageView!.contentMode = .scaleAspectFill
            }
        
            if let iv = coverImageView{
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
            print("speicalItem click do nothing - QQQQ")
            
        /////////////////////////
        /////////////////////////
        case SearchResultItemType.messageItem:
            print("messageItem click do nothing - QQQQ")
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "Share"){(action, index) in
            
            FIRAnalytics.logEvent(withName: "share",parameters:  [:])
            
            switch self.searchResultItems[index.row].type{
            case SearchResultItemType.video:
                let video = self.searchResultItems[index.row] as! VideoSearchResultItem
                
                let shareString = "I saw this great video on Epsilon Stream, https://www.epsilonstream.com: https://youtu.be/\(video.youtubeId)"
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
                
                let shareString = "Check this out: https://itunes.apple.com/us/app/id\(iosApp.appId), shared using Epsilon Stream, https://www.epsilonstream.com ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.gameWebPage:
                let webPage = self.searchResultItems[index.row] as! GameWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream, https://www.epsilonstream.com ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.blogWebPage:
                let webPage = self.searchResultItems[index.row] as! BlogWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream, https://www.epsilonstream.com ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.mathObjectLink:
                let title = (self.searchResultItems[index.row] as! MathObjectLinkSearchResultItem).title

                let shareString = "Check this out: \(title). Shared using Epsilon Stream, https://www.epsilonstream.com ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
    
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.specialItem:
                //QQQQ do something
                print("not implemented yet")

            /////////////////////////
            /////////////////////////
            case SearchResultItemType.messageItem:
                //QQQQ do something
                print("not implemented yet")
                
            }
            
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }
        share.backgroundColor = .green
        
        if isInAdminMode == false{
            return searchResultItems.count > 0 ? [share] : nil
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

            /////////////////////////
            /////////////////////////
            case SearchResultItemType.messageItem:
                print("message item")

                
                
            }
            //Make it disappear
            tableView.setEditing(false, animated: true)
        }

        edit.backgroundColor = .red
        
        //if got down to here then allowing admin mode
        
        
        let pushDown = UITableViewRowAction(style: .normal, title: "Down"){(action, index) in
            
            /*
            for i in 0..<self.searchResultItems.count{
                print("PRI - \(self.searchResultItems[i].foundPriority)")
            }
            */
            
            var newPriority: Float = 0.0
            
            let lastIndex = self.searchResultItems.count - 1
            if index.row == lastIndex || index.row == lastIndex - 1{
                newPriority = self.searchResultItems[lastIndex].foundPriority * 10
                print(newPriority)
            }else{
                let nextPri = self.searchResultItems[index.row+1].foundPriority
                let nextAfterPri =  self.searchResultItems[index.row + 2].foundPriority
                newPriority = (nextPri + nextAfterPri)/2
                print("next: \(nextPri), nextAfter: \(nextAfterPri), new: \(newPriority)")
            }
            
            switch self.searchResultItems[index.row].type{
            case SearchResultItemType.video:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let youTubeIdToPushDown = (self.searchResultItems[index.row] as! VideoSearchResultItem).youtubeId
                EpsilonStreamAdminModel.setCurrentVideo(withVideo: youTubeIdToPushDown)
                EpsilonStreamAdminModel.currentVideo.hashTagPriorities = EpsilonStreamDataModel.newPriorityString(oldHashTagPriorityString: EpsilonStreamAdminModel.currentVideo.hashTagPriorities, forHashTag: EpsilonStreamAdminModel.currentHashTag, withRawPriority: newPriority)
                
                print(EpsilonStreamAdminModel.currentVideo.hashTagPriorities)
                
                EpsilonStreamAdminModel.submitVideo(withDBVideo: EpsilonStreamAdminModel.currentVideo)
                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.iosApp, SearchResultItemType.gameWebPage, SearchResultItemType.blogWebPage:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let id = (self.searchResultItems[index.row] as! FeatureSearchResultItem).ourFeaturedURLHashtag
                EpsilonStreamAdminModel.setCurrentFeature(withFeature: id)
                EpsilonStreamAdminModel.currentFeature.hashTagPriorities = EpsilonStreamDataModel.newPriorityString(oldHashTagPriorityString: EpsilonStreamAdminModel.currentFeature.hashTagPriorities, forHashTag: EpsilonStreamAdminModel.currentHashTag, withRawPriority: newPriority)
                
                print(EpsilonStreamAdminModel.currentFeature.hashTagPriorities)
                
                EpsilonStreamAdminModel.submitFeaturedURL(withDBFeature: EpsilonStreamAdminModel.currentFeature)

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.mathObjectLink:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let id = (self.searchResultItems[index.row] as! MathObjectLinkSearchResultItem).ourMathObjectLinkHashTag
                EpsilonStreamAdminModel.setCurrentMathObjectLink(withHashTag: id)
                EpsilonStreamAdminModel.currentMathObjectLink.hashTagPriorities = EpsilonStreamDataModel.newPriorityString(oldHashTagPriorityString: EpsilonStreamAdminModel.currentMathObjectLink.hashTagPriorities, forHashTag: EpsilonStreamAdminModel.currentHashTag, withRawPriority: newPriority)
                
                print(EpsilonStreamAdminModel.currentMathObjectLink.hashTagPriorities)

                //QQQQ still not updating to cloud

                
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.specialItem:
                print("need to handle")
    
            /////////////////////////
            /////////////////////////
            case SearchResultItemType.messageItem:
                print("need to handle")
                
            }
            //Make it disappear
            tableView.setEditing(false, animated: true)
            self.goingToTop = false
            self.refreshSearch()

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
        coverImageView = UIImageView(image: UIImage(named: "Screen_About_Play"))
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.frame = CGRect(x: window.frame.origin.x, y: window.frame.origin.y, width: window.frame.width, height: window.frame.height)
        window.addSubview(coverImageView)
        UIView.animate(withDuration: 7.0, animations: {
            self.coverImageView.alpha = 0.2
        }, completion:
            {_ in self.coverImageView.removeFromSuperview()})

        storeViewController.modalTransitionStyle = .crossDissolve
        storeViewController.loadProduct(withParameters: parameters)
            {result, error in
                if result {
                    self.present(storeViewController,
                                 animated: false, completion: {
                                    self.coverImageView.removeFromSuperview()})
                }
                
                if error != nil{
                    self.coverImageView.removeFromSuperview() //QQQQ doesn't seem to work
                }
            }
    }
    
    
    @objc func textFieldChange(_ sender: UITextField) {
        if sender.text! ==  webLockKey!{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }
        
    var okAction: UIAlertAction! = nil

    

    func jumpToWebPage(withURLstring string: String, inSafariMode safariMode: Bool = false,withSplashKey splashKey: String = ""){
        if safariMode{
            if webLockKey != nil {
                let alert = UIAlertController(title: "External page", message: "Epsilon Stream is currently web locked. Enter the safety code to allow going to the external page. You can disable weblock in the settings menu.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "Enter 6 character Safety Code"
                }
                let textField = alert.textFields![0] as UITextField
                
                textField.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)

                
                alert.addAction(UIAlertAction(title: "Go to page", style: UIAlertActionStyle.default, handler: {_ in
                    if let url = URL(string: string) {
                        let safariVC = SFSafariViewController(url: url)
                        safariVC.delegate = self
                        self.present(safariVC, animated: true, completion: nil)
                    }
                }))
                okAction = alert.actions[0]
                okAction.isEnabled = false
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
                }))
                self.present(alert, animated: true, completion: nil)

            }else{
                let alert = UIAlertController(title: "You are leaving Epsilon Stream to an external page", message: "If you wish to block such functionallity, you can web lock Epsilon Stream in the settings menu.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Go to page", style: UIAlertActionStyle.default, handler: {_ in
                    if let url = URL(string: string) {
                        let safariVC = SFSafariViewController(url: url)
                        safariVC.delegate = self
                        self.present(safariVC, animated: true, completion: nil)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {_ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
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
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("safariViewControllerDidFinish")
    }
    
}

