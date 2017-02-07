//
//  VideoDetailViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 26/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit
import YouTubePlayer

class YouTubeSearchResultItem{
    var title: String = ""
    var channel: String = ""
    var youtubeId: String = ""//11 chars base 64 youtube id
    var duration: Int = -1
    var imageURL: String = "" //QQQQ
    var image: UIImage? = nil
}

class YouTubeVideoListResultItem{
    var durationString: String = ""
    var durationInt: Int32 = 0
}

class VideoDetailViewController: DetailViewController, YouTubePlayerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, AutoCompleteClientDelegate, YoutubeAPIDelegate {
    
    @IBOutlet weak var hashTagListTextView: UITextView!
    
    @IBOutlet weak var autoCompleteTable: UITableView!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var youtubeSearchTextField: UITextField!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var videoIdLabel: UILabel!
    @IBOutlet weak var youTubeTitleLabel: UILabel!
    @IBOutlet weak var channelKeyTextField: UITextField!
   // @IBOutlet weak var hashTagListTextView: UITextView!
    @IBOutlet weak var ourTitleTextField: UITextField!
    @IBOutlet weak var commentsAndReviewTextView: UITextView!
    @IBOutlet weak var awesomeSwitch: UISwitch!
    @IBOutlet weak var inCollectionSwitch: UISwitch!
    @IBOutlet weak var whyHowSegmentedControl: UISegmentedControl!
    @IBOutlet weak var exploreUnderstandSegmentedControl: UISegmentedControl!
    @IBOutlet weak var age8SegmentedControl: UISegmentedControl!
    @IBOutlet weak var age10SegmentedControl: UISegmentedControl!
    @IBOutlet weak var age12SegmentedControl: UISegmentedControl!
    @IBOutlet weak var age14SegmentedControl: UISegmentedControl!
    @IBOutlet weak var age16SegmentedControl: UISegmentedControl!
    
    let autoCompleteTableDelegate = AutoCompleteTableDelegate()

    
    @IBOutlet weak var viewForPlayer: UIView!
    var videoPlayer: YouTubePlayerView!

    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func channelEditChange(_ sender: UITextField) {
        print("channel edit: \(sender.text!)")
        
    }

    func textViewShouldBeginEditing(_ textView: UITextView){
        if textView.text! == "#needsTag"{
            textView.text! = "#"
        }
    }
    
    func searchCallDone(withItems items: [YouTubeSearchResultItem]){
        youTubeSearchResultItems = items
        tableView.reloadData()
    }
    
    //QQQQ bad bad bad
    var durationInt: Int32 = -1
    
    func videoDetailsCallDone(withItem item: YouTubeVideoListResultItem){
        durationInt = item.durationInt
        durationLabel.text = String(durationInt)
    }


    func textViewDidChange(_ textView: UITextView) {
        if let string = textView.text{
            if string == ""{
                textView.text = "#"
                view.sendSubview(toBack: autoCompleteTable)
            }else{
                autoCompleteTableDelegate.autoCompleteOptions = EpsilonStreamDataModel.autoCompleteListHashTags(string)
                autoCompleteTable.reloadData()
                view.bringSubview(toFront: autoCompleteTable)
                autoCompleteTable.isHidden = false
            }
        }
    }
    
    
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        
        let request = Video.createFetchRequest()
        request.predicate = NSPredicate(format: "youtubeVideoId ==[cd] %@", videoIdLabel.text!)
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let videos = try container.viewContext.fetch(request)
            if videos.count > 1 { //QQQQ troubled here..
                let alert = UIAlertController(title: "One on Epsilon Development", message: "Entry already exists - \(videos.count). GO EDIT THAT ONE.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
        }catch{
            print("Fetch failed")
        }
        
        EpsilonStreamAdminModel.currentVideo.oneOnEpsilonTimeStamp = Date()

        EpsilonStreamAdminModel.currentVideo.youtubeVideoId = videoIdLabel.text!
        EpsilonStreamAdminModel.currentVideo.youtubeTitle = youTubeTitleLabel.text!
                
        EpsilonStreamAdminModel.currentVideo.channelKey = channelKeyTextField.text!
        EpsilonStreamAdminModel.currentVideo.hashTags = hashTagListTextView.text!
        EpsilonStreamAdminModel.currentVideo.ourTitle = ourTitleTextField.text!
        EpsilonStreamAdminModel.currentVideo.commentAndReview = commentsAndReviewTextView.text!
        
        EpsilonStreamAdminModel.currentVideo.isAwesome = awesomeSwitch!.isOn
        EpsilonStreamAdminModel.currentVideo.isInVideoCollection = inCollectionSwitch.isOn
        EpsilonStreamAdminModel.currentVideo.whyVsHow = float4Picker[whyHowSegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.currentVideo.exploreVsUnderstand = float4Picker[exploreUnderstandSegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.currentVideo.age8Rating = float3Picker[age8SegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.currentVideo.age10Rating = float3Picker[age10SegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.currentVideo.age12Rating = float3Picker[age12SegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.currentVideo.age14Rating = float3Picker[age14SegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.currentVideo.age16Rating = float3Picker[age16SegmentedControl.selectedSegmentIndex]
        
        //QQQQ this whole thing of duration isn't handled so cleanly
        EpsilonStreamAdminModel.currentVideo.durationSec = self.durationInt
        
        if let url = urlOfSelectedIndex{
            EpsilonStreamAdminModel.currentVideo.imageURL = url
        }
        if let image = imageOfSelectedIndex{
            EpsilonStreamAdminModel.currentVideo.imageURLlocal = ImageManager.store(image, withKey: EpsilonStreamAdminModel.currentVideo.youtubeVideoId)
        }
        
        EpsilonStreamAdminModel.submitVideo()
        
        //QQQQ copy for next time
        VideoDetailViewController.persistYouTubeSearchResultItems = youTubeSearchResultItems
    }
    
    @IBAction func awesomeSwitchChange(_ sender: UISwitch) {
        
    }
    
    @IBAction func inCollectionSwitchChange(_ sender: UISwitch) {
    }
    
    @IBAction func collectAction(_ sender: UIButton) {
        
        if let index = currentCellIndex{
            timeStampLabel.text = Date().description
            videoIdLabel.text = youTubeSearchResultItems[index].youtubeId
            youTubeTitleLabel.text = youTubeSearchResultItems[index].title
            ourTitleTextField.text = youTubeSearchResultItems[index].title
            channelKeyTextField.text = youTubeSearchResultItems[index].channel //QQQQ calibrate this
            urlOfSelectedIndex = youTubeSearchResultItems[index].imageURL
            imageOfSelectedIndex = youTubeSearchResultItems[index].image

            //At this point this is to get the time duration (not in the search API)
            YoutubeAPICommunicator.getYouTubeAPIVideoInfo(youTubeSearchResultItems[index].youtubeId)

            videoPlayer.removeFromSuperview()
            
            //QQQQ doesn't work
            viewForPlayer.addSubview(UIImageView(image: youTubeSearchResultItems[index].image))
        }
    }
    
    @IBAction func refreshFromYoutube(_ sender: UIButton) {
        print("IMPLEMENT refreshFromYoutube()")
        
        //At this point this is to get the time duration (not in the search API)
        YoutubeAPICommunicator.getYouTubeAPIVideoInfo(EpsilonStreamAdminModel.currentVideo.youtubeVideoId)
    }
    
    var currentCellIndex: Int?
    var urlOfSelectedIndex: String?
    var imageOfSelectedIndex: UIImage?
    
    
    var youTubeSearchResultItems = [YouTubeSearchResultItem]()
    
    static var persistYouTubeSearchResultItems = [YouTubeSearchResultItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPlayer = YouTubePlayerView(frame: viewForPlayer.frame)
        
        videoPlayer.delegate = self
        youtubeSearchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        autoCompleteTableDelegate.delegate = self
        autoCompleteTable.delegate = autoCompleteTableDelegate
        autoCompleteTable.dataSource = autoCompleteTableDelegate
        hashTagListTextView.delegate = self
        
        YoutubeAPICommunicator.delegate = self
    }
    
    func selected(_ string: String){
        hashTagListTextView!.text = string
        //view.sendSubview(toBack: autoCompleteTable)
        autoCompleteTable.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        //QQQQ mutliple text fields on this view controller!!!!
        
        viewForPlayer.addSubview(videoPlayer)
        YoutubeAPICommunicator.getYouTubeAPIFeedVideos(youtubeSearchTextField.text!)
        currentCellIndex = nil
        return false
    }

    
    
    func playerReady(videoPlayer: YouTubePlayerView){
        videoPlayer.play()
    }

    
    override func configureView() {
        //QQQQ
        youTubeSearchResultItems = VideoDetailViewController.persistYouTubeSearchResultItems

        
        if let vid = EpsilonStreamAdminModel.currentVideo{
            mainView.isHidden = false
            
            if let tsLabel = timeStampLabel{
                tsLabel.text = vid.oneOnEpsilonTimeStamp.description
            }
            if let viLabel = videoIdLabel{
                viLabel.text = vid.youtubeVideoId
            }
            if let yttLabel = youTubeTitleLabel{
                yttLabel.text = vid.youtubeTitle
            }
            
            if let ckTextField = channelKeyTextField{
                ckTextField.text = vid.channelKey
            }
            
            if let htlTextView = hashTagListTextView{
                htlTextView.text = vid.hashTags
            }
            if let otTextField = ourTitleTextField{
                otTextField.text = vid.ourTitle
            }

            if let carTextView = commentsAndReviewTextView{
                carTextView.text = vid.commentAndReview
            }

            if let awSwitch = awesomeSwitch{
                awSwitch.isOn = vid.isAwesome
            }

            if let icSwitch = inCollectionSwitch{
                icSwitch.isOn = vid.isInVideoCollection
            }
            
            if let view = viewForPlayer{
                //QQQQ
//                if let im = vid.imagePic{
//                    view.addSubview(UIImageView(image: UIImage(data: im as Data) ))
//                }
            }

            
            if let whsc = whyHowSegmentedControl{
                if let index = floatToIndex4[vid.whyVsHow]{
                    whsc.selectedSegmentIndex = index
                }
            }
            
            if let eusc = exploreUnderstandSegmentedControl{
                if let index = floatToIndex4[vid.exploreVsUnderstand]{
                    eusc.selectedSegmentIndex = index
                }
            }
            
            if let a8sc = age8SegmentedControl, let index = floatToIndex3[vid.age8Rating]{
                a8sc.selectedSegmentIndex = index
            }

            if let a10sc = age10SegmentedControl, let index = floatToIndex3[vid.age10Rating]{
                a10sc.selectedSegmentIndex = index
            }

            if let a12sc = age12SegmentedControl, let index = floatToIndex3[vid.age12Rating]{
                a12sc.selectedSegmentIndex = index
            }

            if let a14sc = age14SegmentedControl, let index = floatToIndex3[vid.age14Rating]{
                a14sc.selectedSegmentIndex = index
            }

            if let a16sc = age16SegmentedControl, let index = floatToIndex3[vid.age16Rating]{
                a16sc.selectedSegmentIndex = index
            }
            
            if let lab = durationLabel{
                durationInt = vid.durationSec
                lab.text = "\(durationInt)"
            }
            
        }else{
            mainView.isHidden = true
        }
    }
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return youTubeSearchResultItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "youTubeSearchCell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        if let image = youTubeSearchResultItems[indexPath.row].image{
            imageView.image = image
        }else{
            imageView.image = UIImage(named: "OneOnEpsilonLogo3")
        }
        
        let titleView = cell.viewWithTag(2) as! UILabel
        titleView.text = youTubeSearchResultItems[indexPath.row].title
        
        let channelView = cell.viewWithTag(3) as! UILabel
        channelView.text = youTubeSearchResultItems[indexPath.row].channel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCellIndex = indexPath.row
        videoPlayer.loadVideoID(youTubeSearchResultItems[currentCellIndex!].youtubeId)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            view.endEditing(true)
            print(textView.text!)
            view.sendSubview(toBack: autoCompleteTable)
            return false
        }
        return true
    }



    
}

