//
//  CurateItemViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 13/6/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

//QQQQ refactor to curateVideoViewController
class CurateItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func updateImageButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker,animated: true)
    }
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var videoIdLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var youtubeTitleLabel: UILabel!
    @IBOutlet weak var channelTitleTextField: UITextField!
    @IBOutlet weak var hashTagListTextView: UITextView!
    @IBOutlet weak var oneOnEpsilonTitleTextField: UITextField!
    @IBOutlet weak var commentsAndReviewTextView: UITextView!
    @IBOutlet weak var awesomeSwitch: UISwitch!
    @IBOutlet weak var inCollectionSwitch: UISwitch!
    @IBOutlet weak var whyHowSegmentedControl: UISegmentedControl!

    @IBAction func refreshFromYoutubeAction(_ sender: UIButton) {
        print("refresh from youtube action")
    }
    
    @IBAction func selectHashTagsAction(_ sender: UIButton) {
        EpsilonStreamAdminModel.selectedHashTagList = EpsilonStreamAdminModel.currentVideo.hashTags
        if let vc = storyboard?.instantiateViewController(withIdentifier: "termSelectorViewController") as? TermSelectorViewController{
            vc.topLabel = oneOnEpsilonTitleTextField.text!
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    
    

    
    @IBAction func submitAction(_ sender: UIButton) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating() //QQQQ continue this
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        view.backgroundColor = UIColor.gray
        backgroundActionInProgress = true
        view.isUserInteractionEnabled = false

        EpsilonStreamAdminModel.currentVideo.oneOnEpsilonTimeStamp = Date() //QQQQ not really used
        EpsilonStreamAdminModel.currentVideo.isInCollection = inCollectionSwitch.isOn
        EpsilonStreamAdminModel.currentVideo.isAwesome = awesomeSwitch.isOn
        
        EpsilonStreamAdminModel.currentVideo.ourTitle = oneOnEpsilonTitleTextField.text!
        
        EpsilonStreamAdminModel.currentVideo.whyVsHow = float4Picker[whyHowSegmentedControl.selectedSegmentIndex]
        EpsilonStreamAdminModel.submitVideo(withDBVideo: EpsilonStreamAdminModel.currentVideo)
        
        DispatchQueue.global(qos: .userInteractive).async {
            while true{
                sleep(1)
                if backgroundActionInProgress == false{
                    self.view.isUserInteractionEnabled = true
                    DispatchQueue.main.sync {
                        spinner.stopAnimating()
                        self.view.backgroundColor = UIColor.white
                    }
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let htl = EpsilonStreamAdminModel.selectedHashTagList{
            EpsilonStreamAdminModel.currentVideo.hashTags = htl
            EpsilonStreamAdminModel.selectedHashTagList = nil
        }
        refreshView()
    }

    func refreshView(){
        //QQQQ timeStampLabel.text = EpsilonStreamAdminModel.currentVideo.oneOnEpsilonTimeStamp as! String
        videoIdLabel.text = EpsilonStreamAdminModel.currentVideo.youtubeVideoId
        durationLabel.text = "\(EpsilonStreamAdminModel.currentVideo.durationSec)"//QQQQ Display duration better
        youtubeTitleLabel.text = EpsilonStreamAdminModel.currentVideo.youtubeTitle
        channelTitleTextField.text = EpsilonStreamAdminModel.currentVideo.channelKey
        hashTagListTextView.text = EpsilonStreamAdminModel.currentVideo.hashTags
        oneOnEpsilonTitleTextField.text = EpsilonStreamAdminModel.currentVideo.ourTitle
        commentsAndReviewTextView.text = EpsilonStreamAdminModel.currentVideo.commentAndReview
        whyHowSegmentedControl.selectedSegmentIndex = floatToIndex4[EpsilonStreamAdminModel.currentVideo.whyVsHow]!
        awesomeSwitch.isOn = EpsilonStreamAdminModel.currentVideo.isAwesome
        inCollectionSwitch.isOn = EpsilonStreamAdminModel.currentVideo.isInCollection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        oneOnEpsilonTitleTextField.delegate = self
        
        refreshView()
    }
   /*
    override func viewDidAppear(){
        super.viewDidAppear()
        
        refreshView()
    }
 */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        guard let _ = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        //print(image)
        dismiss(animated: true, completion: nil)
    }
    
}
