//
//  DetailCell.swift
//  SimpleDailylife
//
//  Created by 始関秀弥 on 2023/02/27.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var previewLabel: UILabel!
    
    var titleString: String? {
        didSet {
            titleLabel.text = titleString
        }
    }
    
    var previewString: String? {
        didSet {
            previewLabel.text = previewString
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLabels(title: String, previewString: String) {
        titleLabel.text = title
        previewLabel.text = previewString
    }
    
}
