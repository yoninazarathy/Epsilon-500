import UIKit

protocol SwitchControlCellDelegate {
    func switchControlCellValueChanged(_ cell: SwitchControlCell)
}

class SwitchControlCell: BaseCell {

    // MARK: - Model
    
    var delegate: SwitchControlCellDelegate?
    
    var isOn: Bool? = false {
        didSet {
            if isOn != oldValue {
                refresh()
            }
        }
    }
    
    // MARK: - UI
    
    let switchControl = UISwitch()
    
    // MARK: - Methods
    
    override func initialize() {
        super.initialize()
        
        switchControl.addTarget(self, action: #selector(switchControlValueChanged(sender:)), for: .valueChanged)
        switchControl.sizeToFit()
        contentView.addSubview(switchControl)
    }
    
    override func refresh() {
        super.refresh()
        
        switchControl.isOn = isOn ?? false
        let size = switchControl.bounds.size
        let origin = CGPoint(x: switchControl.superview!.bounds.size.width - size.width - 10, y: (switchControl.superview!.bounds.height - size.height) / 2 )
        switchControl.frame = CGRect(origin: origin, size: size)
    }
    
    // MARK: - Actions
    
    @objc func switchControlValueChanged(sender: UISwitch) {
        isOn = sender.isOn
        delegate?.switchControlCellValueChanged(self)
    }

}
