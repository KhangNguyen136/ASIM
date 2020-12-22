//
//  filterHistoryCell.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/21/20.
//

import UIKit
import DatePicker

class filterHistoryCell: UITableViewCell {

    @IBOutlet weak var content: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class sectionFilterHistoryCell: UITableViewCell {
    var isOpened : Bool = false
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var content: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if isOpened == true
//        {
////            img.image = UIImage(named: "chevron.up")
//        }
        // Configure the view for the selected state
    }

}

class seclectDateFilterHistoryCell: UITableViewCell {
    var date: Date? = Date()
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func chooseDate(_ sender: UIButton) {
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)!
                let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)!
                // Create picker object
                let datePicker = DatePicker()
                // Setup
                datePicker.setup(beginWith: nil, min: minDate, max: maxDate) { (selected, date) in
                    if selected, let selectedDate = date {
                        self.date = selectedDate
                        sender.setTitle(selectedDate.string(), for: .normal)
                    } else {
                        print("Cancelled")
                    }
                }
                // Display
        datePicker.show(in: self.superview!.parentViewController!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
