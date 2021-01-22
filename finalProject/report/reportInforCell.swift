//
//  reportInfor.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/21/21.
//

import UIKit

class reportInforCell: UITableViewCell {
    

    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var expense: UILabel!
    @IBOutlet weak var income: UILabel!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func getData(t1: String, t2: String, i: Float, e: Float) {
        title1.text = t1
        title2.text = t2
        income.text = String(i)
        
        expense.text = String(e)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
