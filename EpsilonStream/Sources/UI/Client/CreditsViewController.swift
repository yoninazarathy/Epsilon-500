//
//  CreditsViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 29/8/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

    @objc func backClicked(){
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.backgroundColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.alpha = 1.0

        navigationItem.title = "Credits"
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Navigation_Icon_Left_Passive"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn1.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn1)

        
        creditsTextView.text = "\tEpsilon Stream's existence is directly attributed to the incredible artists, expositors and educators that have made thousands of superb mathematics videos and shared them with the world using Youtube. Further, diligent maths bloggers, third party iOS game creators and the Global Math Project team should also be credited.\n\tWithin One on Epsilon Pty Ltd and the Buzz Hunter Creative Agency, contributors to the design, development and content curation of Epsilon Stream include: Elad Ahrak, Nicholas Bartlett, Coco Bu, Hanan Gelbendorf, Phillip Isaac, Igor Kulagin, Inna Lukyanenko, Yousuf Marvi, Dudi Nasi, Yoni Nazarathy, Logan Peck, Miriam Redding, Vladimir Resin, Paul Rozenboim, Iuliia Shestopal, Kirill Trukhin, Cara Urban, Clara Valtorta, Aapeli Vuorinen and Irina Zykova. The community of One on Epsilon includes many dedicated beta testers that help improve the user experience and content experience of Epsilon Stream.\n\t Finally, credit belongs to the distinguished women and men that have contributed to human mathematical knowledge over the past few millennia through mathematical discovery. This discovery continues these days. Keep it going!"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var creditsTextView: UITextView!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
