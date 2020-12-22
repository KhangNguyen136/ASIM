
import UIKit

class historyCell: UITableViewCell {

    var record: polyRecord? = nil
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var descri: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var sourceAccount: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var accImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func getData(_record: polyRecord)  {
        record = _record
        switch record!.type {
        case 0:
            let temp = record!.expense
            let tempStr = categoryValues().expense[temp!.category][temp!.detailCategory]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!)
        case 1:
            let temp = record!.income
            let tempStr = categoryValues().income[0][temp!.category]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!)
//            totalIncome = totalIncome + temp!.amount
        case 2:
            let temp = record?.lend
            let tempStr = categoryValues().other[0][record!.type-2]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!)
            
        case 3:
            let temp = record?.borrow
            let tempStr = categoryValues().other[0][record!.type-2]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!)
        case 4:
            let temp = record?.transfer
            let tempStr = "Transfer"
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!)
        default:
            let temp = record?.adjustment
            let tempStr = "Adjustment"
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.different, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!)
            if temp?.subType == 1
            {
                amount.textColor = UIColor.green
            }
            else
            {
                amount.textColor = UIColor.red
            }
        }
    }
    func loadData(_category: String, describe: String, _amount: Float, _type: Int,srcAccount: String,typeAcc: Int) {
        descri.text = describe
        amount.text = String(_amount)
        category.text = _category
        sourceAccount.text = srcAccount
        if typeAcc == 2
        {
            accImg.image = UIImage(named: "bank")
        }
        switch _type {
        case 0,2:
            amount.textColor = UIColor.red
        case 1,3:
            amount.textColor = UIColor.green
        default:
            amount.textColor = UIColor.black
        }
    }
}
class sectionHistoryCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var income: UILabel!
    @IBOutlet weak var expense: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func getData(_date: String, _income: Float, _expense: Float) {
        date.text = _date
        income.text = String(_income)
        expense.text = String(_expense)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func getData(_date: Date, _income: Float, _expense: Float)  {
    
        date.text = DateFormatter().string(from: _date)
        income.text = String(_income)
        expense.text = String(_expense)
    }

}
