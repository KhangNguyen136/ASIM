//
//  DetailSavingCell.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 1/1/21.
//

import UIKit

class DetailSavingCell: UITableViewCell {
    @IBOutlet weak var lblInterestRate: UILabel!
    
    @IBOutlet weak var lblDescript: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblNameAccFrom: UILabel!
    @IBOutlet weak var lblFinalInterest: UILabel!
    @IBOutlet weak var lblIsavingAcc: UILabel!
    @IBOutlet weak var lblCellInterestRate: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var lblTermEnded: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
