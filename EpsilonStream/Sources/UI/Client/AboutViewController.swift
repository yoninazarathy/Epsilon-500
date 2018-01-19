//
//  AboutViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 27/8/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class AboutViewController: UIPageViewController, UIPageViewControllerDataSource {

    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self

        //navigationController?.navigationBar.barTintColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.backgroundColor = UIColor(rgb: ES_watch1)
        navigationController?.navigationBar.alpha = 1.0
        
        navigationItem.title = "About Epsilon Stream"
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "Navigation_Icon_Left_Passive"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn1.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn1)
        
        view.backgroundColor = UIColor(rgb: ES_watch1)
        view.backgroundColor = UIColor(rgb: ES_watch1)
        view.alpha = 1.0
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    
    }
    
    private lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("aboutIntroViewController"),
                self.newViewController("aboutWatchViewController"),
                self.newViewController("aboutPlayViewController"),
                self.newViewController("aboutExploreViewController"),
                self.newViewController("aboutFeaturesViewController")]
    }()
    
    private func newViewController(_ name: String) -> UIViewController {
        return storyboard!.instantiateViewController(withIdentifier: name)
    }

    // MARK: - Actions
    
    @objc func backClicked(){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
        
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
