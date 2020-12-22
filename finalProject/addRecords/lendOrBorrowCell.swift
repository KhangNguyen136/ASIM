//
//  lendOrBorrowCell.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/10/20.
//

import UIKit

class lendOrBorrowCell: UITableViewCell {
    
    var record: polyRecord? = nil
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var srcAccount: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getData(_record: polyRecord)  {
        record = _record
        if record?.type == 2
        {
            let temp = record?.lend
            let tempStr = categoryValues().other[0][record!.type-2]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.remain, _type: temp!.type)
        }
        else
        {
            let temp = record?.borrow
            let tempStr = categoryValues().other[0][record!.type-2]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.remain, _type: temp!.type)
        }
    }
    func loadData(_category: String, describe: String, _amount: Float, _type: Int) {
        descript.text = describe
        amount.text = String(_amount)
        category.text = _category
        if record?.type == 2
        {
            amount.textColor = UIColor.red
        }
        else
        {
            amount.textColor = UIColor.green
        }
    }

}
