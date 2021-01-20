//
//  DetailSavingAccount.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 1/1/21.
//

import UIKit
import RealmSwift

class DetailSavingAccount: UIViewController {
    @IBOutlet weak var lblBalance: UILabel!
    var nameAcc = ""
    var polysavingAcc: polyAccount? = nil
    var savingAcc: savingAccount = savingAccount()
    var allRecord: [polyRecord] = []
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblInterest: UILabel!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var lblInterestRate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

       self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
        self.navigationItem.title = nameAcc
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "MarkerFelt-Thin", size: 20)!
        ]
        loadData()
        loadRecord()
    }
    
    func loadData(){
        
        lblBalance.text = "\(round((savingAcc.ammount as! Float)*Float(currencyBase().valueBaseDolar[savingAcc.currency]))) \(currencyBase().symbol[savingAcc.currency])"
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        lblStartDate.text = dateFormatter.string(from: savingAcc.startdate)
        lblTerm.text = savingAcc.term
        lblInterest.text = "\( savingAcc.interestRate as! Float)%"
    }
    func loadRecord(){
        let realm = try! Realm()
        let id = polysavingAcc!.id
        let all = Array(realm.objects(polyRecord.self))
        for obj in all{
            //Income
            if obj.type == 1{
                if obj.income?.id == id{
                    allRecord.append(obj)
                }
            }
                //Transfer
            else if obj.type == 4{
                //Tài khoản chuyển vào saving account
                if obj.transfer?.srcAccount?.id == id{
                    allRecord.append(obj)
                }
                else if obj.transfer?.destinationAccount?.id == id{
                    allRecord.append(obj)
                }
                
            }
        }
        

    }

}
extension DetailSavingAccount:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecord.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transaction history"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "DetailSavingCell", for: indexPath) as! DetailSavingCell
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        //Transfer
        let obj = allRecord[indexPath.row]
        if obj.type == 4{
            
            cell.imgIcon.image = UIImage(named:"transfer")
            let transfer = obj.transfer
            let id = polysavingAcc?.id
            //Chuyển từ account đến saving account
            if transfer?.destinationAccount?.id == id{
                cell.lblTermEnded.text = "Send new"
               cell.lblDate.text = dateFormatter.string(from: transfer!.date)
               cell.lblTerm.text = savingAcc.term
               cell.lblCellInterestRate.text = "\(savingAcc.interestRate as! Float)%"
                cell.lblIsavingAcc.text = transfer?.descript
                cell.lblFinalInterest.text = "\(round((transfer?.amount as! Float)*Float(currencyBase().valueBaseDolar[savingAcc.currency]))) \(currencyBase().symbol[savingAcc.currency])"
              
            }
           //Chuyển từ saving account lại account
            else if transfer?.srcAccount?.id == id{
                cell.lblTermEnded.text = "Close"
              cell.lblDate.text = dateFormatter.string(from: transfer!.date)
              cell.lblTerm.text = ""
              cell.lblCellInterestRate.text = ""
                cell.lblIsavingAcc.text = transfer?.descript
               cell.lblFinalInterest.text = "\(round((transfer?.amount as! Float)*Float(currencyBase().valueBaseDolar[savingAcc.currency]))) \(currencyBase().symbol[savingAcc.currency])"
                cell.lblNameAccFrom.text = "\(savingAcc.name)"
            }
           
            }
        // End transfer
        else if obj.type == 1{
            let obj = allRecord[indexPath.row].income
            cell.imgIcon.image = UIImage(named:"interest")
            cell.lblNameAccFrom.text = savingAcc.name
            cell.lblTerm.text = savingAcc.term
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.lblDate.text = dateFormatter.string(from: obj!.date)
            cell.lblFinalInterest.text = "\(round((obj?.amount as! Float)*Float(currencyBase().valueBaseDolar[savingAcc.currency]))) \(currencyBase().symbol[savingAcc.currency])"
            cell.lblIsavingAcc.text = "Interestfrom \(savingAcc.name)"
            var termEnded: String = ""
            if savingAcc.termEnded == 0{
                termEnded = "Rollover principal and interest"
            }
            else if savingAcc.termEnded == 1{
                termEnded = "Rollover principal"
            }
            else {
                termEnded = "Close account"
            }
            cell.lblTermEnded.text = termEnded
            cell.lblCellInterestRate.text = "\(savingAcc.interestRate as! Float)%"
        }
        
       cell.backgroundView = UIImageView(image: UIImage(named: "row"))
       cell.layer.borderWidth = 5
       cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
                  return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}



