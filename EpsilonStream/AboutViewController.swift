//
//  AboutViewController.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 27/8/17.
//  Copyright © 2017 Yoni Nazarathy. All rights reserved.
//

import UIKit

class AboutViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate{

//    var pageControl = UIPageControl()
    
    //QQQQ remove
//    func configurePageControl() {
//        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
//        self.pageControl.numberOfPages = orderedViewControllers.count
//        self.pageControl.currentPage = 0
//        self.pageControl.tintColor = UIColor.green
//        //self.pageControl.alpha = 0.0
//        self.pageControl.pageIndicatorTintColor = UIColor.white
//        self.pageControl.currentPageIndicatorTintColor = UIColor.black
//        self.view.addSubview(pageControl)
//    }
    
    func backClicked(){
        navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        self.delegate = self
        
        //QQQQ configurePageControl()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    
      }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("epsilonStreamIntroViewController"),
                self.newViewController("aboutWatchViewController"),
                self.newViewController("aboutPlayViewController"),
                self.newViewController("aboutExploreViewController"),
                self.newViewController("epsilonStreamCloseViewController")]
    }()
    
    private func newViewController(_ name: String) -> UIViewController {
        return UIStoryboard(name: "EpsilonClient", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
        
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
