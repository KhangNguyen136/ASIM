//
//  categoryCell.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/28/20.
//

import UIKit

class categoryCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    func getData(name: String, imgName: String)  {
        title.text = name
//        icon.image = UIImage(named: "category\(id)")
        icon.image = UIImage(named: imgName)
    }
    
    override func awakeFromNib() {
        icon.clipsToBounds = true
        icon.layer.cornerRadius = icon.frame.width/2
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class detailCategoryCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    func getData(name: String, imgName: String)  {
        title.text = name
        icon.image = UIImage(named: imgName)
    }
    
    override func awakeFromNib() {
        icon.clipsToBounds = true
        icon.layer.cornerRadius = icon.frame.width/2
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

