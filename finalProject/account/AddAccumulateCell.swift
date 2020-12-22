//
//  AddAccumulateCell.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/14/20.
//

import UIKit

class AddAccumulateCell: UITableViewCell {

    @IBOutlet weak var lblremain: UILabel!
    @IBOutlet weak var lblstartBalance: UILabel!
    @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblnowBalance: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
