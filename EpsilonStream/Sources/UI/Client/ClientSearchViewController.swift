//
//  ViewController.swift
//  EpsilonStreamPrototype
//
//  Created by Yoni Nazarathy on 19/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import Alamofire
import StoreKit
import YouTubePlayer
import Firebase
import AVFoundation
import SafariServices


protocol SearcherUI {
    func refreshSearch()
}


class ClientSearchViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AutoCompleteClientDelegate,
SKStoreProductViewControllerDelegate, SFSafariViewControllerDelegate, YouTubePlayerDelegate, SearcherUI {
    
    // MARK: - Model
    
    var audioPlayer: AVAudioPlayer!
    
    var textShuffleTimer: Timer! = nil
    var showXButton = false
    
    let autoCompleteTableDelegate = AutoCompleteTableDelegate()
    
    var searchResultItems = [SearchResultItem]()
    
    var currentSearch = EpsilonStreamSearch()
    
    var goingToTop = true
    
    let mathObjectLinkCreator = MathObjectLinkCreator()
    
    // MARK: - UI
    
    @IBOutlet weak var mainTopStack: UIStackView!
    @IBOutlet weak var mainSegmentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var whyHowSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: SurpriseTextField!
    @IBOutlet weak var ageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var resultsTable: UITableView!
    @IBOutlet weak var autoCompleteTable: UITableView!
    
    var surpriseButton: UIButton! = nil
    var coverImageView: UIImageView! = nil
    
    var okAction: UIAlertAction! = nil
    
    var maintenanceView: MaintenanceView! = nil
    var addMOLinkTextActionView: TextActionView! = nil
    
    // MARK: - Methods
    
    override func initialize() {
        super.initialize()
        
        mathObjectLinkCreator.didChangeState = {
            self.refresh()
        }
        mathObjectLinkCreator.didChangeSearchString = {
            self.refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        surpriseButton.imageView!.animationImages = [UIImage(named: "Surprise4")!, UIImage(named: "Surprise1")!,
                                                     UIImage(named: "Surprise2")!, UIImage(named: "Surprise5")!,
                                                     UIImage(named: "Surprise3")!, UIImage(named: "Surprise6")!]
        surpriseButton.imageView!.animationDuration = 0.4
        surpriseButton.addTarget(self, action: #selector(supriseButtonAction), for: .touchUpInside)

        searchTextField.rightViewMode = .always
        searchTextField.rightView = surpriseButton
        searchTextField.text = ""

        autoCompleteTable.isHidden = true
        autoCompleteTable.separatorStyle = .none
        
        EpsilonStreamBackgroundFetch.searcherUI = self
      
        //
        maintenanceView = MaintenanceView()
        maintenanceView.actions[.mathObjectLink] = {
            self.mathObjectLinkCreator.confirmStartCreateMathObjectLink(withHashTag:  EpsilonStreamAdminModel.currentHashTag, confirmation: { (confirmed) in
                if (confirmed) {
                    self.resultsTable.setContentOffset(.zero, animated: true)
                }
            })
        }
        
        addMOLinkTextActionView = TextActionView()
        addMOLinkTextActionView.text = LocalString("CreateMOLinkText")
        addMOLinkTextActionView.buttonTitle = LocalString("CreateMOLinkActionButton")
        addMOLinkTextActionView.action = {
            self.mathObjectLinkCreator.confirmFinishCreateMathObjectLink()
        }
        addMOLinkTextActionView.closeAction = {
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.mathObjectLinkCreator.reset()
            })
        }
        //

        view.backgroundColor = UIColor(rgb: ES_watch1)
        view.alpha = 1.0
 
        refreshSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        unregisterKeyboardNotifications()
        //AppUtility.lockOrientation(.all)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        refreshSearch()
    }
    
    override func refresh() {
        guard shouldRefresh else {
            return
        }
        refreshAutoCompleteTableView()
        
        var origin = CGPoint.zero
        var size = CGSize(width: resultsTable.bounds.size.width, height: 60)
        maintenanceView.frame = CGRect(origin: origin, size: size)
        if isInAdminMode {
            resultsTable.tableFooterView = maintenanceView
        } else {
            resultsTable.tableFooterView = nil
        }
        
        addMOLinkTextActionView.actionButtonIsEnabled = (mathObjectLinkCreator.state == .enterSearchTerm) && (mathObjectLinkCreator.searchString.isEmpty == false)
        origin = CGPoint.zero
        size = CGSize(width: resultsTable.bounds.size.width, height: 60)
        addMOLinkTextActionView.frame = CGRect(origin: origin, size: size)
        if isInAdminMode && mathObjectLinkCreator.state == .enterSearchTerm {
            resultsTable.tableHeaderView = addMOLinkTextActionView
        } else {
            resultsTable.tableHeaderView = nil
        }
    }
    
    func refreshAutoCompleteTableView() {
        ViewFactory.shared.refreshScrollViewInsets(scrollView: autoCompleteTable, withKeyboardFrame: keyboardFrame)
    }
    
    func refreshSearch(){
        
        if searchTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""{
            homeButton.isEnabled = false
        }else{
            homeButton.isEnabled = true
        }
        
        //QQQQ this is duplicated elsewhere
        if  showXButton{
            surpriseButton.setImage(UIImage(named: "EraseIconSmall"), for: .normal)
        }else{
            surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
        }
        
        
        currentSearch.searchString = searchTextField.text!
        if (mathObjectLinkCreator.hashTag.isEmpty == false) {
            mathObjectLinkCreator.searchString = currentSearch.searchString
        }

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
        if goingToTop == true {
            resultsTable.contentOffset = .zero
        }
        goingToTop = true //QQQ super nasty hack
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
    
    func updateSearchString(_ string: String){
        var search = EpsilonStreamSearch()
        search.searchString = string
        if (mathObjectLinkCreator.hashTag.isEmpty == false) {
            mathObjectLinkCreator.searchString = string
        }
        if string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""{//QQQQ user can enter "home"
            BrowseStackManager.pushNew(search: search)
        }
        searchTextField.text = string
        autoCompleteTable.isHidden = true
        refreshSearch()
        self.view.endEditing(true)
        
        Analytics.logEvent("item_selected", parameters: ["string" : string as NSObject])
    }
    
    func clearSearchText() {
        UserMessageManager.userDidAnotherAction()
        
        if let prevText = searchTextField.text{
            Analytics.logEvent("clear_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            Analytics.logEvent("clear_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        searchTextField.text = "" //QQQQ or home?
        refreshSearch()
        showXButton = false
        //QQQQ duplicated
        surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
    }
    
    func makeActionWithSearchResultItem(_ searchResultItem: SearchResultItem) {
        switch searchResultItem.type {
        case .video:
            let videoItem = searchResultItem as! VideoSearchResultItem
            openVideoItem(videoItem)
        /////////////////////////
        case .iosApp:
            Analytics.logEvent("appStore_go", parameters: ["appId" :  (searchResultItem as! IOsAppSearchResultItem).appId as NSObject])
            jumpToIosApp(withCode: (searchResultItem as! IOsAppSearchResultItem).appId) //QQQQ
        /////////////////////////
        case .gameWebPage:
            Analytics.logEvent("gameWeb_go", parameters: ["webURL" :  (searchResultItem as! GameWebPageSearchResultItem).url as NSObject])
            jumpToWebPage(withURLstring: (searchResultItem as! GameWebPageSearchResultItem).url, withSplashKey: "gameQQQQ")
        /////////////////////////
        case .blogWebPage:
            Analytics.logEvent("web_go", parameters: ["webURL" :  (searchResultItem as! BlogWebPageSearchResultItem).url as NSObject])
            jumpToWebPage(withURLstring: (searchResultItem as! BlogWebPageSearchResultItem).url,
                          inSafariMode: (searchResultItem as! BlogWebPageSearchResultItem).isExternal,
                          withSplashKey: searchResultItem.splashKey)
        /////////////////////////
        case .mathObjectLink:
            //QQQQ implement math object link search result item
            let molItem = searchResultItem as! MathObjectLinkSearchResultItem
            
            Analytics.logEvent("mathObjectLink_go", parameters: ["link_name" :  molItem.ourMathObjectLinkHashTag as NSObject])
            
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
            
            updateSearchString(molItem.searchTitle)
            
        /////////////////////////
        case .specialItem:
            DLog("speicalItem click do nothing - QQQQ")
            
        /////////////////////////
        case .messageItem:
            DLog("messageItem click do nothing - QQQQ")
            
        /////////////////////////
        case .snippet:
            if let snippet = Snippet.findOne(byPropertyWithName: BaseCoreDataModel.recordNameProperty, value: searchResultItem.recordName) {
                AppLogic.shared.openSnippet(snippet as! Snippet)
            }
        }
    }
    
    // MARK: - View controllers
    
    func openVideoItem(_ item: VideoSearchResultItem) {
        Analytics.logEvent("video_play", parameters: ["videoId" : item.youtubeId as NSObject])
        
        let secondsWatched = UserDataManager.getSecondsWatched(forKey: item.youtubeId)
        
        let playVideo = { (resumeSeconds: Int) -> Void in
            let vc = PlayVideoViewController()
            vc.isExplodingDots = false //QQQQ read type of video display here
            vc.videoIdToPlay = item.youtubeId
            vc.startSeconds = resumeSeconds
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if secondsWatched > 0 {
        
            AlertManager.shared.showResumePlayback(seconds: secondsWatched, confirmation: { (confirmed, _) in
                if confirmed {
                    playVideo(secondsWatched)
                } else {
                    playVideo(0)
                }
            })
            
        } else {
            
            playVideo(0)
            
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResultItems.count == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialCell", for: indexPath) as! SpecialItemTableViewCell
                cell.mainLabel.text = "No match for \"\(currentSearch.searchString)\""
                cell.clientSearchViewController = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MathObjectLinkCell", for: indexPath) as! MathObjectLinkItemTableViewCell
                cell.configureWith(searchResult: searchResultItems[0] as! MathObjectLinkSearchResultItem)
                return cell
            }
        }
        
        let searchResultItem = searchResultItems[indexPath.row]
        
        switch searchResultItem.type {
            
        case .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoItemTableViewCell
            cell.configureWith(videoSearchResult: searchResultItem as! VideoSearchResultItem)
            return cell
            
        case .iosApp:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameItemTableViewCell
            cell.configureWith(searchResult: searchResultItem)
            return cell
            
        case .gameWebPage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameItemTableViewCell
            cell.configureWith(searchResult: searchResultItem)
            return cell
            
        case .blogWebPage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleItemTableViewCell
            cell.configureWith(searchResult: searchResultItem as! BlogWebPageSearchResultItem)
            return cell
            
        case .mathObjectLink:
            //QQQQ implement Math ObjectLink Search Result Item
            let cell = tableView.dequeueReusableCell(withIdentifier: "MathObjectLinkCell", for: indexPath) as! MathObjectLinkItemTableViewCell
            cell.configureWith(searchResult: searchResultItem as! MathObjectLinkSearchResultItem)
            return cell
            
        case .specialItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpecialCell", for: indexPath) as! SpecialItemTableViewCell
            cell.configureWith(specialSearchResultItem: searchResultItem as! SpecialSearchResultItem)
            return cell
            
        case .messageItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as! UserMessageTableViewCell
            cell.configureWith(userMessageResultItem: searchResultItem as! UserMessageResultItem)
            return cell
            
        case .snippet:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell", for: indexPath) as! SnippetItemTableViewCell
            cell.configureWith(searchResult: searchResultItem)
            return cell
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        //QQQQ this is a horrible hack - make cleaner
        if searchResultItems.count == 0 {// && searchResultItems[0].type == SearchResultItemType.mathObjectLink{
            return 1
        } else {
            return searchResultItems.count
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //will be if there is no search.
        //QQQQ fix this so it acts better on the "Let our team known"
        if searchResultItems.count == 0 {
            if let text = searchTextField.text {
                Analytics.logEvent("no_search", parameters: ["stringSearch" : text as NSObject])
            } else {
                Analytics.logEvent("no_search", parameters: ["stringSearch" : "EMPTY" as NSObject])
            }
            return
        }
        //
        
        makeActionWithSearchResultItem(searchResultItems[indexPath.row])
    }
    
    //QQQQ Igor - refactor?
    static func shareID(of videoID: String) -> String{
        let modifiedID = videoID.lowercased().replacingOccurrences(of: "_", with: "e").replacingOccurrences(of: "-", with: "e")
        return String(modifiedID.prefix(11).suffix(6)) //QQQQ how to use strings in swift???
    }
    
    static func shareSnippetID() -> String{
        let modifiedID = EpsilonStreamAdminModel.currentHashTag.lowercased().dropFirst()
        return String(modifiedID)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let searchResultItem = self.searchResultItems[indexPath.row]
        
        let share = UITableViewRowAction(style: .normal, title: "Share"){(action, index) in
            
            Analytics.logEvent("share",parameters: nil)
            
            switch searchResultItem.type {
            case .video:
                let video = self.searchResultItems[index.row] as! VideoSearchResultItem
                
                let shareString = "I saw this great mathematics video on Epsilon Stream: https://epsilonstream.com/video/\(ClientSearchViewController.shareID(of: video.youtubeId)) . Check it out!"
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
            case .iosApp:
                let iosApp = self.searchResultItems[index.row] as! IOsAppSearchResultItem
                
                let shareString = "Check this out: https://itunes.apple.com/us/app/id\(iosApp.appId), shared using Epsilon Stream, https://oneonepsilon.com/epsilonstream ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
                
                
                /////////////////////////
            /////////////////////////
            case .gameWebPage:
                let webPage = self.searchResultItems[index.row] as! GameWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream, https://oneonepsilon.com/epsilonstream ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
                
                
                /////////////////////////
            /////////////////////////
            case .blogWebPage:
                let webPage = self.searchResultItems[index.row] as! BlogWebPageSearchResultItem
                
                let shareString = "Check this out: \(webPage.url), shared using Epsilon Stream, https://oneonepsilon.com/epsilonstream ."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
                /////////////////////////
            /////////////////////////
            case .mathObjectLink:
                //let title = (self.searchResultItems[index.row] as! MathObjectLinkSearchResultItem).title
                
                let shareString = "Check out Epsilon Stream, https://oneonepsilon.com/epsilonstream."
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
                
                /////////////////////////
            /////////////////////////
            case .specialItem:
                DLog("not implemented yet")
                
                /////////////////////////
            /////////////////////////
            case .messageItem:
                DLog("not implemented yet")
            
            case .snippet:
                let shareString = "I saw this great mathematical description in Epsilon Stream. Check it out. https://epsilonstream.com/snippet/\(ClientSearchViewController.shareSnippetID())"
                let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.resultsTable.cellForRow(at: index) //QQQQ how to make this have the popover on the share button (ipads?)
                self.present(vc, animated:  true)
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
            switch searchResultItem.type {
            case .video:
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
            case .mathObjectLink:
                let moLink = MathObjectLink.findOne(byPropertyWithName: "recordName", value: searchResultItem.recordName) as! MathObjectLink
                AppLogic.shared.editMathObjectLink(moLink)
            case .specialItem:
                DLog("need to implement edit (or not)")
                
                /////////////////////////
            /////////////////////////
            case .messageItem:
                DLog("message item")
            case .snippet:
                DLog("snippet item")
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
            case .video:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let youTubeIdToPushDown = (self.searchResultItems[index.row] as! VideoSearchResultItem).youtubeId
                EpsilonStreamAdminModel.setCurrentVideo(withVideo: youTubeIdToPushDown)
                EpsilonStreamAdminModel.currentVideo.hashTagPriorities = EpsilonStreamDataModel.newPriorityString(oldHashTagPriorityString: EpsilonStreamAdminModel.currentVideo.hashTagPriorities, forHashTag: EpsilonStreamAdminModel.currentHashTag, withRawPriority: newPriority)
                
                print(EpsilonStreamAdminModel.currentVideo.hashTagPriorities)
                
                EpsilonStreamAdminModel.submitVideo(withDBVideo: EpsilonStreamAdminModel.currentVideo)
                
                /////////////////////////
            /////////////////////////
            case .iosApp, .gameWebPage, .blogWebPage:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let id = (self.searchResultItems[index.row] as! FeatureSearchResultItem).ourFeaturedURLHashtag
                EpsilonStreamAdminModel.setCurrentFeature(withFeature: id)
                EpsilonStreamAdminModel.currentFeature.hashTagPriorities = EpsilonStreamDataModel.newPriorityString(oldHashTagPriorityString: EpsilonStreamAdminModel.currentFeature.hashTagPriorities, forHashTag: EpsilonStreamAdminModel.currentHashTag, withRawPriority: newPriority)
                
                print(EpsilonStreamAdminModel.currentFeature.hashTagPriorities)
                
                EpsilonStreamAdminModel.submitFeaturedURL(withDBFeature: EpsilonStreamAdminModel.currentFeature)
                
                
                /////////////////////////
            /////////////////////////
            case .mathObjectLink:
                //isInAdminMode = true//QQQQ ?? Maybe this isn't needed here
                let id = (self.searchResultItems[index.row] as! MathObjectLinkSearchResultItem).ourMathObjectLinkHashTag
                EpsilonStreamAdminModel.setCurrentMathObjectLink(withHashTag: id)
                EpsilonStreamAdminModel.currentMathObjectLink.hashTagPriorities = EpsilonStreamDataModel.newPriorityString(oldHashTagPriorityString: EpsilonStreamAdminModel.currentMathObjectLink.hashTagPriorities, forHashTag: EpsilonStreamAdminModel.currentHashTag, withRawPriority: newPriority)
                
                print(EpsilonStreamAdminModel.currentMathObjectLink.hashTagPriorities)
                
                //QQQQ still not updating to cloud
                
                
                /////////////////////////
            /////////////////////////
            case .specialItem:
                DLog("need to handle")
                
                /////////////////////////
            /////////////////////////
            case .messageItem:
                DLog("need to handle")
            case .snippet:
                DLog("not supported")
                
            }
            
            //Make it disappear
            tableView.setEditing(false, animated: true)
            self.goingToTop = false
            self.refreshSearch()
        }
        
        pushDown.backgroundColor = .orange
        
        return [share, edit, pushDown]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if let footerView = self.tableView(tableView, viewForFooterInSection: section) {
//            return footerView.bounds.height
//        }
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if tableView == resultsTable && isInAdminMode == true {
//            return maintenanceView
//        }
//        return nil
//    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        refreshSearch()
        autoCompleteTable.isHidden = true
        return false
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        DLog("safariViewControllerDidFinish")
    }
    
    // MARK: - Keyboard
    override func keyboardFrameUpdated() {
        refreshAutoCompleteTableView()
    }
    
    // MARK: - Actions
    
    @IBAction func homeButtonAction(_ sender: Any) {
        UserMessageManager.userDidAnotherAction()
        
        if let prevText = searchTextField.text{
            Analytics.logEvent("home_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            Analytics.logEvent("home_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        searchTextField.text = "" //QQQQ or home?
        BrowseStackManager.reset(withBaseSearch: EpsilonStreamSearch())
        refreshSearch()
        showXButton = false
        //QQQQ duplicated
        surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        UserMessageManager.userDidAnotherAction()
        
        if let prevText = searchTextField.text{
            Analytics.logEvent("back_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            Analytics.logEvent("back_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        
        let newSearchText = BrowseStackManager.moveBack().searchString
        print(newSearchText)
        searchTextField.text = newSearchText
        refreshSearch()
    }
    
    @IBAction func forwardButtonAction(_ sender: UIButton) {
        UserMessageManager.userDidAnotherAction()
        if let prevText = searchTextField.text{
            Analytics.logEvent("forward_button", parameters: ["prevText" : prevText as NSObject])
        }else{
            Analytics.logEvent("forward_button", parameters: ["prevText" : "EMPTY" as NSObject])
        }
        searchTextField.text = BrowseStackManager.moveForward().searchString
        refreshSearch()
    }
    
    @IBAction func supriseButtonAction(_ sender: UIButton) {
        UserMessageManager.userDidAnotherAction()
        
        if showXButton{
            clearSearchText()
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
                Analytics.logEvent("surprise_button", parameters: ["newText" : newText as NSObject])
                self.updateSearchString(newText)
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
    
    @IBAction func searchFieldEditBegin(_ sender: Any) {
        if searchTextField.text! != ""{
            showXButton = true
            surpriseButton.setImage(UIImage(named: "EraseIconSmall"), for: .normal)
        }
    }
    
    @IBAction func searchEditChange(_ sender: UITextField) {
        UserMessageManager.userDidKeyInAction()
        let searchString = sender.text!.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //QQQQ duplicated
        if searchString == ""{
            showXButton = false
            surpriseButton.setImage(UIImage(named: "Surprise4"), for: .normal)
        }else{
            showXButton = true
            surpriseButton.setImage(UIImage(named: "EraseIconSmall"), for: .normal)
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
        }else{
            view.sendSubview(toBack: autoCompleteTable)
            autoCompleteTable.isHidden = true
        }
        refreshSearch()
    }
    
    @objc func textFieldChange(_ sender: UITextField) {
        okAction.isEnabled = (sender.text! == webLockKey!)
    }
    
    //   var whyVsHow = 0
     /*
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
}
