//
//  AutoCompleteTableDelegate.swift
//  EpsilonStream
//
//  Created by Yoni Nazarathy on 30/12/16.
//  Copyright © 2016 Yoni Nazarathy. All rights reserved.
//

import UIKit

protocol AutoCompleteClientDelegate {
    func selected(_ string: String)
}

class AutoCompleteTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var autoCompleteOptions: [String] = []
    
    var delegate: AutoCompleteClientDelegate?
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return autoCompleteOptions.count
    }
    
    
    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "autoCompleteTableCell2", for: indexPath)
        
        cell.textLabel!.text = autoCompleteOptions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       print("Selected row at \(indexPath.row)")
        if let del = delegate{
            del.selected(autoCompleteOptions[indexPath.row])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40 //QQQQ
    }
    
}
