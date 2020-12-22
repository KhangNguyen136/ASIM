//
//  PickAccountCell.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/21/20.
//

import UIKit

class PickAccountCell: UITableViewCell {

    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblBalance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
