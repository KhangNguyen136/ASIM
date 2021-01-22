
import UIKit
import RealmSwift
class historyCell: UITableViewCell {

    var record: polyRecord? = nil
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var descri: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var sourceAccount: UILabel!
    @IBOutlet weak var img: UIImageView!
    var currency = 0
    @IBOutlet weak var accImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func loadAmountByCurrency(value: Float) -> Float
    {
        if currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[currency])
    }
    func getData(_record: polyRecord, _currency: Int)  {
        record = _record
        currency = _currency
        switch record!.type {
        case 0:
            let temp = record!.expense
            let tempStr = categoryValues().expense[temp!.category][temp!.detailCategory]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!, imgName: "category\(temp!.category)\(temp!.detailCategory)")
        case 1:
            let temp = record!.income
            let tempStr = categoryValues().income[0][temp!.category]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!, imgName: "income\(temp!.category)")
//            totalIncome = totalIncome + temp!.amount
        case 2:
            let temp = record?.lend
            let tempStr = categoryValues().other[0][record!.type-2]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!, imgName: "typeRecord2")
            
        case 3:
            let temp = record?.borrow
            let tempStr = categoryValues().other[0][record!.type-2]
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!, imgName: "typeRecord3")
        case 4:
            let temp = record?.transfer
            let tempStr = "Transfer"
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.amount, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!, imgName: "typeRecord4")
        default:
            let temp = record?.adjustment
            let tempStr = "Adjustment"
            var imgName = ""
            if temp?.subType == 1
            {
                amount.textColor = UIColor.green
                imgName = "income\(temp!.detailCategory)"
            }
            else
            {
                amount.textColor = UIColor.red
                imgName = "category\(temp!.category)\(temp!.detailCategory)"

            }
            loadData(_category: tempStr, describe: temp!.descript, _amount: temp!.different, _type: temp!.type, srcAccount: (temp?.srcAccount?.getname())!, typeAcc: (temp?.srcAccount!.type)!,imgName: imgName)
            
        }
    }
    func loadData(_category: String, describe: String, _amount: Float, _type: Int,srcAccount: String,typeAcc: Int, imgName: String) {
        descri.text = describe
        amount.text = String(loadAmountByCurrency(value: _amount))
        category.text = _category
        sourceAccount.text = srcAccount
        if typeAcc == 2
        {
            accImg.image = UIImage(named: "bank")
        }
        img.image = UIImage(named: imgName)
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
    var currency = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadAmountByCurrency(value: Float) -> Float
    {
        if currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[currency])
    }
    func getData(_date: String, _income: Float, _expense: Float, _currency: Int) {
        date.text = _date
        currency = _currency
        income.text = String(loadAmountByCurrency(value: _income)) + " " + currencyBase().symbol[currency]
        expense.text = String(loadAmountByCurrency(value: _expense)) + " " + currencyBase().symbol[currency]

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
