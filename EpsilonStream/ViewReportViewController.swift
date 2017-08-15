//
//  ViewReportViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 24/6/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class ViewReportViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainTextView.delegate = self
        
        // Do any additional setup after loading the view.
        
        mainTextView.text = EpsilonStreamAdminModel.mathObjectReport()
        mainTextView.isEditable = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        
        let shareString = mainTextView.text!
        let vc = UIActivityViewController(activityItems: [shareString], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        self.present(vc, animated:  true)
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
