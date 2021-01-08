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

    @IBOutlet weak var lblComlete: UILabel!
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
    func showComplete(condition: Bool){
        lblComlete.layer.borderColor = CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
        lblComlete.layer.cornerRadius = 8
         lblComlete.layer.borderWidth = 1
         lblComlete.textAlignment = .center
        if condition{
            lblComlete.isHidden = false
            lblremain.isHidden = true
        }
        else {
            lblComlete.isHidden = true
        }
    }

}
