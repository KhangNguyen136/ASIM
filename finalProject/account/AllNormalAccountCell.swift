//
//  AllNormalAccountCell.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/5/20.
//

import UIKit

class AllNormalAccountCell: UITableViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMoney: UILabel!
    @IBOutlet weak var btnOption: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
