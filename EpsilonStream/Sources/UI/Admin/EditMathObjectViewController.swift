//
//  EditMathObjectViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 15/7/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

//https://stackoverflow.com/questions/27218669/swift-dictionary-get-key-for-value
extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.0
    }
}

class EditMathObjectViewController: UIViewController {
    
    //QQQQ consolidate this
    let editorOptions = [ "All":      0,
                          "None":     1,
                          "Coco":     2,
                          "Inna":     3,
                          "Phil":     4,
                          "Yoni":     5,
                          "Yousuf":   6,
                          "Igor":     7]

    
    @IBOutlet weak var inCollectionSwitch: UISwitch!
    @IBAction func submitChangeButton(_ sender: UIButton) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.tintColor = UIColor.black
        spinner.startAnimating() //QQQQ continue this
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        view.backgroundColor = UIColor.gray
        backgroundActionInProgress = true
        view.isUserInteractionEnabled = false
        
        print(curatorSegment.selectedSegmentIndex)
        print(reviewerSegment.selectedSegmentIndex)

        EpsilonStreamAdminModel.currentMathObject.curator = editorOptions.someKey(forValue: curatorSegment.selectedSegmentIndex)!
        EpsilonStreamAdminModel.currentMathObject.reviewer = editorOptions.someKey(forValue: reviewerSegment.selectedSegmentIndex)!
        EpsilonStreamAdminModel.currentMathObject.isInCollection = inCollectionSwitch.isOn
        
        
        EpsilonStreamAdminModel.submitMathObject()
        
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
        
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var curatorSegment: UISegmentedControl!
    
    @IBOutlet weak var reviewerSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mo = EpsilonStreamAdminModel.currentMathObject{
            navigationItem.title = mo.hashTag
            curatorSegment.selectedSegmentIndex = editorOptions[mo.curator]!
            reviewerSegment.selectedSegmentIndex = editorOptions[mo.reviewer]!
            inCollectionSwitch.isOn = mo.isInCollection
        }else{
            navigationItem.title = "Error: No Math Object"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
