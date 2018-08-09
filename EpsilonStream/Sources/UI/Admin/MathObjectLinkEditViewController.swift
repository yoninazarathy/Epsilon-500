import UIKit

// Move to better place

struct TitleValueModel {
    var title = ""
    var value = ""
}

class MathObjectLinkEditViewController: TextEditViewController, SwitchControlCellDelegate {

    // MARL: - Model
    
    var titleValueModels = [IndexPath: TitleValueModel]()
    
    var mathObjectLink: MathObjectLink? {
        didSet {
            editObject = mathObjectLink
        }
    }
    
    var generalSection = 0
    
    var hashTagsRow             = 0
    var searchTitleRow          = 0
    var searchPriorityRow       = 0
    var hashTagPrioritiesRow    = 0
    var imageURLRow             = 0
    var ourTitleRow             = 0
    var ourTitleDetailRow       = 0
    var isInCollectionRow       = 0
    
    override func initialize() {
        super.initialize()
        
        title = LocalString("MathObjectLinkEditViewScreenTitle")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func refreshRowAndSectionIndeces() {
        super.refreshRowAndSectionIndeces()
        
        generalSection = 0
        
        hashTagsRow             = 0
        searchTitleRow          = hashTagsRow + 1
        searchPriorityRow       = searchTitleRow + 1
        hashTagPrioritiesRow    = searchPriorityRow + 1
        imageURLRow             = hashTagPrioritiesRow + 1
        ourTitleRow             = imageURLRow + 1
        ourTitleDetailRow       = ourTitleRow + 1
        isInCollectionRow       = ourTitleDetailRow + 1
        numberOfRowsInSections.append(isInCollectionRow + 1)
        
        let searchPriorityString = (mathObjectLink != nil) ? "\(mathObjectLink!.displaySearchPriority)" : ""
        titleValueModels.removeAll()
        addTitleValueModel(row: hashTagsRow,            section: 0, title: "Hashtags",              value: mathObjectLink?.hashTags)
        addTitleValueModel(row: searchTitleRow,         section: 0, title: "Search title",          value: mathObjectLink?.searchTitle)
        addTitleValueModel(row: searchPriorityRow,      section: 0, title: "Search priority",       value: searchPriorityString)
        addTitleValueModel(row: hashTagPrioritiesRow,   section: 0, title: "Hashtag priorities",    value: mathObjectLink?.hashTagPriorities)
        addTitleValueModel(row: imageURLRow,            section: 0, title: "Image URL",             value: mathObjectLink?.imageURL)
        addTitleValueModel(row: ourTitleRow,            section: 0, title: "Our title",             value: mathObjectLink?.ourTitle)
        addTitleValueModel(row: ourTitleDetailRow,      section: 0, title: "Our title detail",      value: mathObjectLink?.ourTitleDetail)
        addTitleValueModel(row: isInCollectionRow,      section: 0, title: "Is in collection",      value: nil)
    }
    
    override func refresh() {
        super.refresh()
    }
    
    func addTitleValueModel(row: Int, section: Int, title: String, value: String?) {
        titleValueModels[ IndexPath(row: row, section: section) ] = TitleValueModel(title: title, value: value ?? "")
    }
    
    func saveText(_ text: String, toPropertyAtIndexPath indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if (section == generalSection) {
            if row == hashTagsRow {
                
                mathObjectLink?.hashTags = text
                
            } else if row == searchTitleRow {
                
                mathObjectLink?.searchTitle = text
                
            } else if row == searchPriorityRow {
                
                mathObjectLink?.displaySearchPriority = Float(text) ?? mathObjectLink!.displaySearchPriority
                
            } else if row == hashTagPrioritiesRow {
                
                mathObjectLink?.hashTagPriorities = text
                
            } else if row == imageURLRow {
                
                mathObjectLink?.imageURL = text
                
            } else if row == ourTitleRow {
                
                mathObjectLink?.ourTitle = text
                
            } else if row == ourTitleDetailRow {
                
                mathObjectLink?.ourTitleDetail = text
                
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellClass = UITableViewCell.self
        if indexPath.section == generalSection && indexPath.row == isInCollectionRow {
            cellClass = SwitchControlCell.self
        }
        
        let cellID = String(describing: cellClass)
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = cellClass.init(style: .value1, reuseIdentifier: cellID)
        }
        
        let titleValueModel = titleValueModels[indexPath]!
        cell?.textLabel?.text = titleValueModel.title
        cell?.detailTextLabel?.text = titleValueModel.value
        
        if indexPath.section == generalSection && indexPath.row == isInCollectionRow {
            let switchCell = cell as? SwitchControlCell
            switchCell?.delegate = self
            switchCell?.isOn = mathObjectLink?.isInCollection
        }
        
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
            
            if confirmed {
                self.saveText(text ?? "", toPropertyAtIndexPath: indexPath)
                self.refreshRowAndSectionIndeces()
                self.tableView.reloadData()
            }
            
        }
    }
    
    // MARK: - SwitchControlCellDelegate
    
    func switchControlCellValueChanged(_ cell: SwitchControlCell) {
        let indexPath = tableView.indexPath(for: cell)
        if indexPath?.section == generalSection {
            if indexPath?.row == isInCollectionRow {
                mathObjectLink?.isInCollection = cell.isOn!
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
