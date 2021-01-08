//
//  accountCell.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/29/20.
//

import UIKit

class accountCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var accountName: UILabel!
    
    @IBOutlet weak var balance: UILabel!
    
    func getData(acc: polyAccount)  {
        if acc.type == 0
        {
            let temp = acc.cashAcc
            img.image = UIImage(named: "wallet")
            accountName.text = temp?.name
            balance.text = String(temp!.balance)
        }
        else
        {
            let temp = acc.bankingAcc
            img.image = UIImage(named: "bank")
            accountName.text = temp?.name
            balance.text = String(temp!.balance)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
