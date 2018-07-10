import UIKit

class TextEditViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Model
    
    var editObject: AnyObject? {
        didSet {
            if editObject !== oldValue {
                tableView.reloadData()
                refresh()
            }
        }
    }
    
    var numberOfSections = 1
    var numberOfRowsInSections = [Int]()

    // MARK: - UI

    lazy var cancelBarButtonItem = UIBarButtonItem(title: LocalString("CommonTextCancel"), style: .plain,
                                                   target: self, action: #selector(cancelButtonPressed(sender:)) )
    lazy var doneBarButtonItem = UIBarButtonItem(title: LocalString("CommonTextDone"), style: .done,
                                                 target: self, action: #selector(doneButtonPressed(sender:)) )
   
    lazy var tableView = UITableView(frame: .zero, style: .grouped)
    
    override func initialize() {
        super.initialize()
    }
    
    override func loadView() {
        super.loadView()

        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    override func refresh() {
        super.refresh()
        
        refreshRowAndSectionIndeces()
        
        let origin = CGPoint.zero
        let size = view.bounds.size
        tableView.frame = CGRect(origin: origin, size: size)
    }
    
    func refreshRowAndSectionIndeces() {
        numberOfRowsInSections.removeAll()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSections[section]
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Actions
    
    @objc func cancelButtonPressed(sender: UIButton) {
        close()
    }
    
    @objc func doneButtonPressed(sender: UIButton) {
        
    }
}
