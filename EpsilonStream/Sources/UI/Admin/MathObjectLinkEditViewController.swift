import UIKit

// Move to better place

struct TitleValueModel {
    var title = ""
    var value = ""
}

class MathObjectLinkEditViewController: TextEditViewController {

    // MARL: - Model
    
    var titleValueModels = [IndexPath: TitleValueModel]()
    
    var mathObjectLink: MathObjectLink? {
        didSet {
            editObject = mathObjectLink
        }
    }
    
    var hashTagsRow             = 0
    var searchTitleRow          = 0
    var searchPriorityRow       = 0
    var hashTagPrioritiesRow    = 0
    var imageURLRow             = 0
    
    override func initialize() {
        super.initialize()
        
        title = LocalString("MathObjectLinkEditViewScreenTitle")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func refreshRowAndSectionIndeces() {
        super.refreshRowAndSectionIndeces()
        
        hashTagsRow             = 0
        searchTitleRow          = hashTagsRow + 1
        searchPriorityRow       = searchTitleRow + 1
        hashTagPrioritiesRow    = searchPriorityRow + 1
        imageURLRow             = hashTagPrioritiesRow + 1
        numberOfRowsInSections.append(imageURLRow + 1)
        
        let searchPriorityString = (mathObjectLink != nil) ? "\(mathObjectLink!.displaySearchPriority)" : ""
        titleValueModels.removeAll()
        addTitleValueModel(row: hashTagsRow,            section: 0, title: "Hashtags",              value: mathObjectLink?.hashTags)
        addTitleValueModel(row: searchTitleRow,         section: 0, title: "Search title",          value: mathObjectLink?.searchTitle)
        addTitleValueModel(row: searchPriorityRow,      section: 0, title: "Search priority",       value: searchPriorityString)
        addTitleValueModel(row: hashTagPrioritiesRow,   section: 0, title: "Hashtag priorities",    value: mathObjectLink?.hashTagPriorities)
        addTitleValueModel(row: imageURLRow,            section: 0, title: "Image URL",             value: mathObjectLink?.imageURL)
    }
    
    override func refresh() {
        super.refresh()
    }
    
    func addTitleValueModel(row: Int, section: Int, title: String, value: String?) {
        titleValueModels[ IndexPath(row: row, section: section) ] = TitleValueModel(title: title, value: value ?? "")
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        }
        
        let titleValueModel = titleValueModels[indexPath]!
        
        cell?.textLabel?.text = titleValueModel.title
        cell?.detailTextLabel?.text = titleValueModel.value
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let row = indexPath.row
        
        let titleValueModel = titleValueModels[indexPath]!
        var keyboardType = UIKeyboardType.default
        if row == searchPriorityRow || row == hashTagPrioritiesRow {
            keyboardType = .decimalPad
        }
        AlertManager.shared.showTextField(withText: titleValueModel.value, message: titleValueModel.title, keyboardType: keyboardType) { (confirmed, text) in
            
            let finalText = text ?? ""
            
            if confirmed {
                if row == self.hashTagsRow {
                    
                    self.mathObjectLink?.hashTags = finalText
                    
                } else if row == self.searchTitleRow {
                    
                    self.mathObjectLink?.searchTitle = finalText
                    
                } else if row == self.searchPriorityRow {
                    
                    self.mathObjectLink?.displaySearchPriority = Float(finalText) ?? self.mathObjectLink!.displaySearchPriority
                
                } else if row == self.hashTagPrioritiesRow {
                    
                    self.mathObjectLink?.hashTagPriorities = finalText
                
                } else if row == self.imageURLRow {
                    
                    self.mathObjectLink?.imageURL = finalText
                    
                }
                
                self.refreshRowAndSectionIndeces()
                self.tableView.reloadData()
            }
            
        }
    }
    
    // MARK: - Actions
    
    override func cancelButtonPressed(sender: UIButton) {
        super.cancelButtonPressed(sender: sender)
        
        mathObjectLink?.discardChanges()
    }
    
    override func doneButtonPressed(sender: UIButton) {
        AlertManager.shared.showWait()
        mathObjectLink?.updateCloudRecord(completion: { (error) in
            AlertManager.shared.closeWait()
            if error != nil {
                AlertManager.shared.showError(error: error!)
            } else {
                self.close()
            }
        })
    }
    
}
