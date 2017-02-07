//
//  MathObjectDetailViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 26/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit

class MathObjectDetailViewController: DetailViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hashTagTextField: UITextField!
    @IBOutlet weak var associatedTextView: UITextView!
    
    @IBAction func submitClicked(_ sender: UIButton) {
        
        let request = MathObject.createFetchRequest()
        request.predicate = NSPredicate(format: "hashTag ==[cd] %@", hashTagTextField.text!)
        
        do{
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let mathObjects = try container.viewContext.fetch(request)
            if mathObjects.count > 1{
                let alert = UIAlertController(title: "One on Epsilon Development", message: "Entry already exists - \(mathObjects.count). GO EDIT THAT ONE.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
        }catch{
            print("Fetch failed")
        }
        
        EpsilonStreamAdminModel.currentMathObject.oneOnEpsilonTimeStamp = Date()
        EpsilonStreamAdminModel.currentMathObject.hashTag = hashTagTextField.text!
        EpsilonStreamAdminModel.currentMathObject.associatedTitles = associatedTextView.text!
        
        print("submitting....")
        
        EpsilonStreamAdminModel.submitMathObject()
        
    }
    override func configureView() {
        
        //QQQQ these go elsewhere?
        hashTagTextField.delegate = self
        associatedTextView.delegate = self
        
        if let mo = EpsilonStreamAdminModel.currentMathObject{
            mainView.isHidden = false
            if let label = dateLabel{
                label.text = mo.oneOnEpsilonTimeStamp.description
            }
            
            if let textField = hashTagTextField{
                textField.text = mo.hashTag
            }
            
            if let textView = associatedTextView{
                textView.text = mo.associatedTitles
            }
        }else{
            mainView.isHidden = true
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
