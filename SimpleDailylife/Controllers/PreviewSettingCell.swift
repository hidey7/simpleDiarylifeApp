//
//  PreviewSettingCell.swift
//  SimpleDailylife
//
//  Created by 始関秀弥 on 2023/05/23.
//

import UIKit

class PreviewSettingCell: UITableViewCell {

    @IBOutlet weak var previewStateSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        previewStateSwitch.isOn = !AppSettings.shared.previewIsHidden
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchPreviewState(_ sender: Any) {
        AppSettings.switchPreviewState()
    }
    
    
}
