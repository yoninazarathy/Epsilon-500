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
    
    var hashtagsRow = 0
    var searchTitleRow = 0
    var searchPriorityRow = 0
    
    override func initialize() {
        super.initialize()
        
        title = LocalString("MathObjectLinkEditViewScreenTitle")
    }
    
    override func loadView() {
        super.loadView()
    
    }
    
    override func refreshRowAndSectionIndeces() {
        super.refreshRowAndSectionIndeces()
        
        hashtagsRow = 0
        searchTitleRow = hashtagsRow + 1
        searchPriorityRow = searchTitleRow + 1
        numberOfRowsInSections.append(searchPriorityRow + 1)
        
        let searchPriorityString = (mathObjectLink != nil) ? "\(mathObjectLink!.displaySearchPriority)" : ""
        titleValueModels.removeAll()
        addTitleValueModel(row: hashtagsRow,        section: 0, title: "Hashtags",          value: mathObjectLink?.hashTags)
        addTitleValueModel(row: searchTitleRow,     section: 0, title: "Search title",      value: mathObjectLink?.searchTitle)
        addTitleValueModel(row: searchPriorityRow,  section: 0, title: "Search priority",   value: searchPriorityString)
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
        
        let titleValueModel = titleValueModels[indexPath]!
        AlertManager.shared.showTextField(withText: titleValueModel.value, message: titleValueModel.title) { (confirmed, text) in
            
            let finalText = text ?? ""
            
            if confirmed {
                if indexPath.row == self.hashtagsRow {
                    
                    self.mathObjectLink?.hashTags = finalText
                    
                } else if indexPath.row == self.searchTitleRow {
                    
                    self.mathObjectLink?.searchTitle = finalText
                    
                } else if indexPath.row == self.searchPriorityRow {
                    
                    self.mathObjectLink?.displaySearchPriority = Float(finalText) ?? self.mathObjectLink!.displaySearchPriority
                }
                
                self.refreshRowAndSectionIndeces()
                self.tableView.reloadData()
            }
            
        }
    }
    
    // MARKL - Actions
    
    override func doneButtonPressed(sender: UIButton) {
        
    }
    
}
