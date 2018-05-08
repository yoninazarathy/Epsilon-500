import UIKit

enum MaintenanceAction: Int {
    case open
    case cancel
    case mathObjectLink
}

class CellMaintenanceView: BaseView {
    
    // MARK: - Model
    var actions = [MaintenanceAction: () -> ()]()
    
    // MARK: - UI
    let scrollView = UIScrollView()
    var buttons = [UIButton]()
    var cancelButton: UIButton!
    
    // MARK: - Methods
    
    override func initialize() {
        backgroundColor = UIColor(white: 1, alpha: 0.8)
        
        addSubview(scrollView)
        
        cancelButton = button(withTitle: LocalString("CellMaintenanceViewCancel"), maintenanceAction: .cancel)
        addSubview(cancelButton)
        
        buttons.append(button(withTitle: LocalString("CellMaintenanceViewOpen"), maintenanceAction: .open))
        buttons.append(button(withTitle: LocalString("CellMaintenanceViewMathObjectLink"), maintenanceAction: .mathObjectLink))
        
        for button in buttons {
            scrollView.addSubview(button)
        }
    }
    
    override func refresh() {
        super.refresh()
        
        let gap = CGFloat(10)
        let buttonSize = CGSize(width: 100, height: 40)
        
        //
        var size = CGSize(width: 70, height: buttonSize.height)
        var origin = CGPoint(x: bounds.size.width - size.width - gap, y: (bounds.size.height - size.height) / 2)
        cancelButton.frame = CGRect(origin: origin, size: size)
        //
        
        //
        origin = .zero
        size = CGSize(width: cancelButton.frame.origin.x, height: bounds.height)
        scrollView.frame = CGRect(origin: origin, size: size)
        //
        
        //
        let rows = 2
        let yGap = (scrollView.bounds.height - CGFloat(rows) * buttonSize.height) / (CGFloat(rows + 1))
        for (i, button) in buttons.enumerated() {
            origin = CGPoint(x: gap + (buttonSize.width + gap) * CGFloat(i / rows), y: yGap + (buttonSize.height + yGap) * CGFloat(i % rows))
            size = buttonSize
            button.frame = CGRect(origin: origin, size: size)
        }
        scrollView.contentSize = CGSize(width: gap + (buttonSize.width + gap) * CGFloat(buttons.count), height: scrollView.bounds.height)
        //
    }
    
    func button(withTitle title: String, maintenanceAction: MaintenanceAction) -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonPressed(sender:)) )
        button.setTitle(title)
        button.setTitleColor(.blue)
        button.tag = maintenanceAction.rawValue
        button.layer.borderWidth = 2
        button.layer.borderColor = button.titleColor(for: .normal)?.cgColor
        button.layer.cornerRadius = 5
        button.registerBorderColorEvents()
        DLog("button.titleColor(for: .normal)?")
        return button
    }
    
    // MARK: - Action
    
    @objc func buttonPressed(sender: UIButton) {
        let action = MaintenanceAction(rawValue: sender.tag)
        actions[action!]?()
    }
}
