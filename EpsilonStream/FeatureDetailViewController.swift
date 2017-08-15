//
//  FeatureDetailViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 26/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit

class FeatureDetailViewController: DetailViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var isAppSwitch: UISwitch!
    @IBOutlet weak var labelTimeStamp: UILabel!
 
    
    @IBOutlet weak var ourTitleHashTags: UITextView!
    @IBOutlet weak var ourTitleTextView: UITextView!
    @IBOutlet weak var imageURLTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var ourDescriptionTextView: UITextView!
    @IBOutlet weak var ourFeaturedURLHashTag: UITextField!
    
    @IBAction func submitAction(_ sender: UIButton) {
        let request = FeaturedURL.createFetchRequest()
        request.predicate = NSPredicate(format: "ourFeaturedURLHashtag ==[cd] %@", ourFeaturedURLHashTag.text!)
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let featuredURLs = try container.viewContext.fetch(request)
            if featuredURLs.count > 1{
                let alert = UIAlertController(title: "One on Epsilon Development", message: "Entry already exists - \(featuredURLs.count). GO EDIT THAT ONE.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
        }catch{
            print("Fetch failed")
        }
        
        EpsilonStreamAdminModel.currentFeature.oneOnEpsilonTimeStamp = Date()
        EpsilonStreamAdminModel.currentFeature.isAppStoreApp = isAppSwitch.isOn
        EpsilonStreamAdminModel.currentFeature.urlOfItem = urlTextField.text!
        EpsilonStreamAdminModel.currentFeature.hashTags = ourTitleHashTags.text!
        EpsilonStreamAdminModel.currentFeature.imageURL = imageURLTextField.text!
        EpsilonStreamAdminModel.currentFeature.imageKey = nil //QQQQ
        EpsilonStreamAdminModel.currentFeature.ourTitle = ourTitleHashTags.text! //QQQQ
        EpsilonStreamAdminModel.currentFeature.ourDescription = ourDescriptionTextView.text!
        EpsilonStreamAdminModel.currentFeature.ourFeaturedURLHashtag = ourFeaturedURLHashTag.text!
        
        EpsilonStreamAdminModel.currentFeature.typeOfFeature = "article"//QQQQ
        
        
        print("submitting....")
        
        //QQQQ EpsilonStreamAdminModel.submitFeaturedURL()
    }
    override func configureView() {
        ourTitleHashTags.delegate = self
        ourTitleTextView.delegate = self
        urlTextField.delegate = self
        imageURLTextField.delegate = self
        ourDescriptionTextView.delegate = self
        ourFeaturedURLHashTag.delegate = self
        
        
        if let fu = EpsilonStreamAdminModel.currentFeature{
            if let label = labelTimeStamp{
                label.text = fu.oneOnEpsilonTimeStamp.description
            }
            
            if let appSwitch = isAppSwitch{
                appSwitch.isOn = fu.isAppStoreApp
            }
            
            if let otht = ourTitleHashTags{
                otht.text = fu.ourTitle
            }

            if let ottv = ourTitleTextView{
                ottv.text = fu.ourTitle
            }

            if let imURL = imageURLTextField{
                imURL.text = fu.imageURL
            }

            if let urlTF = urlTextField{
                urlTF.text = fu.urlOfItem
            }
            
            if let odtv = ourDescriptionTextView{
                odtv.text = fu.ourDescription
            }
            
            if let ofURL = ourFeaturedURLHashTag{
                ofURL.text = fu.ourFeaturedURLHashtag
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        print(textField.text!)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            view.endEditing(true)
            print(textView.text!)
            return false
        }
        return true
    }
    
}
