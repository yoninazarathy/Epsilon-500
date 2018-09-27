//
//  CurateArticleViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 13/6/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

//QQQQ rename to CurateFeature
class CurateArticleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ourTitleTextField: UITextField!
    @IBOutlet weak var imageURLLabel: UILabel!
    @IBOutlet weak var imageKeyLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var ourFeaturedURLHashtagLabel: UILabel!
    @IBOutlet weak var providerLabel: UITextField!
    @IBOutlet weak var hashTagListTextView: UITextView!
    @IBOutlet weak var ourDescriptionTextField: UITextField!
    @IBOutlet weak var awesomeSwitch: UISwitch!
    @IBOutlet weak var inCollectionSwitch: UISwitch!
    @IBOutlet weak var whyHowSegmentedControl: UISegmentedControl!
    @IBOutlet weak var commentsAndReviewTextView: UITextView!
    
    
    @IBAction func urlWebAction(_ sender: UIButton) {
    }
    
    @IBAction func imageKeyMakeAction(_ sender: UIButton) {
    }
    
    @IBAction func imageURLAction(_ sender: UIButton) {
    }
    
    @IBAction func selectHashTagAction(_ sender: Any) {
        EpsilonStreamAdminModel.selectedHashTagList = EpsilonStreamAdminModel.currentFeature.hashTags
        if let vc = storyboard?.instantiateViewController(withIdentifier: "termSelectorViewController") as? TermSelectorViewController{
            vc.topLabel = ourTitleTextField.text!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func updateImageAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker,animated: true)

    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating() //QQQQ continue this
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        view.backgroundColor = UIColor.gray
        backgroundActionInProgress = true
        view.isUserInteractionEnabled = false
        
        EpsilonStreamAdminModel.currentFeature.isInCollection = inCollectionSwitch.isOn
        // QQQQ EpsilonStreamAdminModel.currentFeature.isAwesome = awesomeSwitch.isOn
        EpsilonStreamAdminModel.currentFeature.whyVsHow = float4Picker[whyHowSegmentedControl.selectedSegmentIndex]
        
        EpsilonStreamAdminModel.submitFeaturedURL(withDBFeature: EpsilonStreamAdminModel.currentFeature)
        
        DispatchQueue.global(qos: .userInteractive).async {
            while true{
                sleep(1)
                if backgroundActionInProgress == false{
                    self.view.isUserInteractionEnabled = true
                    DispatchQueue.main.sync {
                        spinner.stopAnimating()
                        self.view.backgroundColor = UIColor.white
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push To Cloud", style: .plain, target: self, action: #selector(self.submitAction))
                    }
                    break
                }
            }
        }
    }

    func refreshView() {
        imageKeyLabel.text = EpsilonStreamAdminModel.currentFeature.imageKey
        ourFeaturedURLHashtagLabel.text = EpsilonStreamAdminModel.currentFeature.ourFeaturedURLHashtag
        ourTitleTextField.text = EpsilonStreamAdminModel.currentFeature.ourTitle
        providerLabel.text = EpsilonStreamAdminModel.currentFeature.provider
        hashTagListTextView.text = EpsilonStreamAdminModel.currentFeature.hashTags
        ourDescriptionTextField.text = EpsilonStreamAdminModel.currentFeature.ourDescription
        urlLabel.text = EpsilonStreamAdminModel.currentFeature.urlOfItem
        //QQQQ no awesome awesomeSwitch = EpsilonStreamAdminModel.currentFeature
        inCollectionSwitch.isOn = EpsilonStreamAdminModel.currentFeature.isInCollection
        //QQQQ whyHowSegmentedControl = EpsilonStreamAdminModel.currentFeature.
        //QQQQ commentsAndReviewTextView = EpsilonStreamAdminModel.currentFeature.
        //whyHowSegmentedControl.selectedSegmentIndex = floatToIndex4[EpsilonStreamAdminModel.currentVideo.whyVsHow]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push To Cloud", style: .plain, target: self, action: #selector(submitAction))
        
        refreshView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let htl = EpsilonStreamAdminModel.selectedHashTagList{
            EpsilonStreamAdminModel.currentFeature.hashTags = htl
            EpsilonStreamAdminModel.selectedHashTagList = nil
        }
        refreshView()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        //guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        //print(image)
        dismiss(animated: true, completion: nil)
    }
    
}
