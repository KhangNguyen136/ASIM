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
    
    func getData(acc: polyAccount,currency: Int, hideAmount: Bool)  {
        if acc.type == 0
        {
            let temp = acc.cashAcc
            img.image = UIImage(named: "wallet")
            accountName.text = temp?.name
            if hideAmount == false
            {
                var tempBalance: Float = temp!.balance
                if currency != 0
                {
                    tempBalance = tempBalance * Float(currencyBase().valueBaseDolar[currency])
                }
            balance.text = String(tempBalance) + " " + currencyBase().symbol[currency]
            }
            else
            {
                balance.text = "******" + " " + currencyBase().symbol[currency]
            }
        }
        else
        {
            let temp = acc.bankingAcc
            img.image = UIImage(named: "bank")
            accountName.text = temp?.name
            if hideAmount == false
            {
                var tempBalance: Float = temp!.balance
                if currency != 0
                {
                    tempBalance = tempBalance * Float(currencyBase().valueBaseDolar[currency])
                }
            balance.text = String(tempBalance) + " " + currencyBase().symbol[currency]
            }
            else
            {
                balance.text = "******" + " " + currencyBase().symbol[currency]
            }
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
