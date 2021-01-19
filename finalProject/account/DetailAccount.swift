//
//  DetailAccount.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 1/14/21.
//

import UIKit
import RealmSwift

class DetailAccount: UIViewController {
    var Acc: polyAccount? = nil
    var allRecord: [polyRecord] = []
    var recordByDate: [(key:String,value :[polyRecord])]? = nil
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var lblExpense: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    override func viewDidLoad() {
        if Acc?.type == 0{
            lblBalance.text = "\(round((Acc?.cashAcc?.balance as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!]))) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
        }
        else{
            lblBalance.text = "\(round((Acc?.bankingAcc?.balance as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!]))) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
        }
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationItem.title = "Detail Account"
        loadRecord()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let dictionary = Dictionary(grouping: allRecord, by: { dateFormatter.string(from: $0.getDate()) })

        recordByDate = dictionary.sorted { (first, second) -> Bool in
            return dateFormatter.date(from: first.key)! > dateFormatter.date(from: second.key)!
        }

        //print("Dictionary",dictionary[0][0])
        // Do any additional setup after loading the view.
    }
    func loadRecord(){
        let realm = try! Realm()
        let record = Array(realm.objects(polyRecord.self))
        for obj in record{
            let srcAcc = obj.srcAccount()
            if Acc?.getname() == srcAcc.getname(){
                allRecord.append(obj)
            }
        }
        
    }

}
extension DetailAccount: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (Array(recordByDate!)[section].value).count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return recordByDate!.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (Array(recordByDate!))[section].key
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailAccountCell", for: indexPath) as! DetailAccountCell
        let obj = (Array(recordByDate!)[indexPath.section]).value[indexPath.row]
        switch obj.type {
        case 0:
            let expense = obj.expense
            let categ = categoryValues().expense[expense!.category][expense!.detailCategory]
            cell.lblTitle.text = categ
            if(Acc?.type == 0){
                cell.lblAmount.text = "\((expense?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!])) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
            }
            else{
                cell.lblAmount.text = "\((expense?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.bankingAcc!.currency)!])) \(currencyBase().symbol[(Acc?.bankingAcc?.currency)!])"
            }
            cell.imgIcon.image = UIImage(named: categ)
            cell.lblContent.text = ""
            break;
        case 1:
            let income = obj.income
            let categ = categoryValues().income[0][income!.category]
                   cell.lblTitle.text = categ
            if(Acc?.type == 0){
                cell.lblAmount.text = "\((income?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!])) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
            }
            else{
                cell.lblAmount.text = "\((income?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.bankingAcc!.currency)!])) \(currencyBase().symbol[(Acc?.bankingAcc?.currency)!])"
            }
            cell.lblContent.text = income?.descript
                   break;
        case 2:
            let lend = obj.lend
            cell.lblTitle.text = "Lend"
            if(Acc?.type == 0){
                cell.lblAmount.text = "\((lend?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!])) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
            }
            else{
                cell.lblAmount.text = "\((lend?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.bankingAcc!.currency)!])) \(currencyBase().symbol[(Acc?.bankingAcc?.currency)!])"
            }
            cell.imgIcon.image = UIImage(named: "Lend")
            cell.lblContent.text = lend?.descript
            break;
        case 3:
            let borrow = obj.borrow
           cell.lblTitle.text = "Borrow"
           if(Acc?.type == 0){
               cell.lblAmount.text = "\((borrow?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!])) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
           }
           else{
               cell.lblAmount.text = "\((borrow?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.bankingAcc!.currency)!])) \(currencyBase().symbol[(Acc?.bankingAcc?.currency)!])"
           }
           cell.imgIcon.image = UIImage(named: "Borrow")
            cell.lblContent.text = borrow?.descript
           break;
        case 4:
            //Trường hợp source account )
            
         let transfer = obj.transfer
         if transfer?.srcAccount?.getname() == Acc?.getname(){
            cell.lblTitle.text = "Transfer to \(transfer?.destinationAccount?.getname() as! String)"
            cell.lblAmount.text = "\(transfer?.amount as! Float)$"
            cell.imgIcon.image = UIImage(named: "Transfer")
             cell.lblContent.text = transfer?.descript
         }
         else if transfer?.destinationAccount?.getname() == Acc?.getname(){
            cell.lblTitle.text = "Transfer from \(transfer?.destinationAccount?.getname() as! String)"
            if(Acc?.type == 0){
                cell.lblAmount.text = "\((transfer?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.cashAcc!.currency)!])) \(currencyBase().symbol[(Acc?.cashAcc?.currency)!])"
            }
            else{
                cell.lblAmount.text = "\((transfer?.amount as! Float)*Float(currencyBase().valueBaseDolar[(Acc?.bankingAcc!.currency)!])) \(currencyBase().symbol[(Acc?.bankingAcc?.currency)!])"
            }
            
            cell.imgIcon.image = UIImage(named: "Transfer")
             cell.lblContent.text = transfer?.descript
         }
         
        break;
        case 5:
            let adj = obj.adjustment
            let categ = categoryValues().expense[adj!.category][adj!.detailCategory]
            cell.lblTitle.text = categ
            cell.lblAmount.text = "\(adj?.amount as! Float)đ"
            cell.imgIcon.image = UIImage(named: categ)
            cell.lblContent.text = "Adjustment account balance"
            break;
            
        default:
            break;
        }
        //
        cell.backgroundView = UIImageView(image: UIImage(named: "row"))
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
           return cell
    }
}

