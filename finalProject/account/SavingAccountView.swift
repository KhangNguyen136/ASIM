//
//  SavingAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/15/20.
//

import UIKit
import RealmSwift
import SCLAlertView
class SavingAccountView: UIViewController {
    var activeAcc: [polyAccount] = []
    var closeAcc: [polyAccount] = []
    @IBOutlet weak var lblamount: UILabel!
    @IBOutlet weak var lblNumAcc: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        savingAccount().updateInterest()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
               // Do any additional setup after loading the view.
        self.navigationItem.title = "Saving account"
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        tableView.reloadData()
    }
    func loadData(){
        self.activeAcc = []
        self.closeAcc = []
       let realm = try! Realm()
        let acc = Array(realm.objects(polyAccount.self).filter("type == 2"))
        for obj in acc{
            if obj.savingAcc?.state == false{
                self.activeAcc.append(obj)
            }
            else{
                self.closeAcc.append(obj)
            }
        }
       
       var total: Float = 0.0
        for bal in self.activeAcc{
            total += bal.savingAcc!.ammount
       }
        lblamount.text = "\(total)"
        lblNumAcc.text = "(\(self.activeAcc.count) account)"
   }
}
extension SavingAccountView: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = ["Active saving account", "Closed saving account"]
        return title[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return closeAcc.count
        }
        return activeAcc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllSavingAccountCell", for: indexPath) as! AllSavingAccountCell
        if indexPath.section == 0{
        cell.imgIcon.image = UIImage(named: "bank")
            cell.lblName.text = activeAcc[indexPath.row].savingAcc!.bank
            cell.lblRate.text = "\( activeAcc[indexPath.row].savingAcc!.interestRate)%"
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.lblDate.text = dateFormatter.string(from: activeAcc[indexPath.row].savingAcc!.startdate)
            cell.lblAmount.text = "\(activeAcc[indexPath.row].savingAcc!.ammount) đ"
        }
        else{
            cell.imgIcon.image = UIImage(named: "bank")
            cell.lblName.text = closeAcc[indexPath.row].savingAcc!.bank
            cell.lblRate.text = "\( closeAcc[indexPath.row].savingAcc!.interestRate)%"
            let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.lblDate.text = dateFormatter.string(from: closeAcc[indexPath.row].savingAcc!.startdate)
            cell.lblAmount.text = "\(closeAcc[indexPath.row].savingAcc!.ammount) đ"
            
        }
        //
        cell.backgroundView = UIImageView(image: UIImage(named: "row"))
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
           return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: "Delete"){
                (action, view, nil) in
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("OK") {
                    let obj = self.activeAcc[indexPath.row]
                    let realm = try! Realm()
                    let records = realm.objects(Income.self).filter("id == \(obj.savingAcc!.id)")
                    try! realm.write{
                        realm.delete(records)
                    }
                    obj.del()
                    self.loadData()
                    tableView.reloadData()
                       
                    }
                alertView.addButton("Exit") {
                           }
                alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this saving Account will also be removed and cannot be restored ")
                
            }
            delete.image = UIImage(named: "delete")
            delete.backgroundColor = UIColor.white
        //Deposit choice
        let close = UIContextualAction(style: .normal, title: "Close"){
                (action, view, nil) in
           
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Exit") {
                                      }
            let dateFormatter = DateFormatter()
                   dateFormatter.dateFormat = "MM/dd/yyyy"
            let realm = try! Realm()
            let obj = self.activeAcc[indexPath.row].savingAcc

            let startDate =  obj!.startdate
            let term = obj!.term
            var dateComponent = DateComponents()
            switch term{
            case "1 week", "2 weeks", "3 weeks":
                let addDays = Int(term.components(separatedBy: " ")[0]) as! Int
                dateComponent.day = addDays*7
            case "1 month", "3 months", "6 months", "12 months":
                let addMonths = Int( term.components(separatedBy: " ")[0]) as! Int
                dateComponent.month = addMonths
            default:
                dateComponent.day = 0
            }
             let endDate = Calendar.current.date(byAdding: dateComponent, to: startDate)!
            var nextTerm = obj!.nextTermDate
            let termEnded = obj!.termEnded
            let interestPaid = obj!.interestPaid
            let srcAcc = obj!.srcAccount
            let destAcc = obj!.destAccount
            let interestRate = obj!.interestRate*0.01
            //Số ngày tính từ thời điểm bắt đầu đến kì hạn
            let timeTerm = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
            let termDays = timeTerm.day!
            //Số ngày tính lãi 1 năm
            let numDays = obj!.numDays
            //amount
            let amount = obj!.ammount
            //freeInterest
            let freeInterestRate = obj!.freeInterestRate*0.01
                //Maturity
            if interestPaid == 0{
                //Gốc + lãi
                if termEnded == 0 {
                    
                    let timeTerm = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
                     //So ngay tinh thoi thoi diem hien tai tru di ngay bat dau
                    let termDays = timeTerm.day!
                    let termInterest = Float(termDays)/Float(numDays)*interestRate
                    //Số ngày tính từ thời điểm bắt đầu đến hiện tại
                    let timeRemain = Calendar.current.dateComponents([.day], from: Date(), to: nextTerm)
                    //Số ngày tính từ hiện tại tới ngày tính lãi sắp tiếp
                    let remainDays = timeRemain.day!
                    //Số ngày đã qua tính từ lần cuối tính lãi đến hiện tại
                    let passDaysInTerm = termDays - remainDays
                    let timePass = Calendar.current.dateComponents([.day], from: startDate, to: nextTerm)
                    //Số ngày tính từ thời điểm bắt đầu đến hiện tại
                    let passDays = timePass.day!
                    let temp1 = Float(passDays/termDays)
                    let estimateInterest = pow(1+termInterest,temp1)*amount-amount
                    let finalInterest = Float(passDaysInTerm)/Float(termDays)*freeInterestRate/Float(numDays)*amount
                    /* let newincome = Income()
                        newincome.id = obj.id
                    nextTerm =  Calendar.current.date(byAdding: dateComponent, to: nextTerm)!
                     try! realm.write{
                          newincome.getData(_amount: finalInterest, _type: 1, _descript: "", _srcAccount: srcAcc!, _person: "", _location: "", _event: "", _srcImg: "", _date: nextTerm, _category: 3, _lendRecord: nil)*/
                    alertView.addButton("OK") {
                    let transfer = Transfer()
                    transfer.id = self.activeAcc[indexPath.row].savingAcc!.id
                    try! realm.write{
                        transfer.getData(_amount: obj!.ammount, _type: 4, _descript: "", _srcAccount: self.activeAcc[indexPath.row], _location: "", _srcImg: "", _date: Date(), _destAccount: obj!.srcAccount!, _transferFee: nil)
                        obj?.state = true
                        obj?.srcAccount?.income(_amount: obj!.ammount)
                        
                        }
                        transfer.add()
                    self.loadData()
                    tableView.reloadData()
                    }
                    alertView.showWarning("Attention", subTitle: "This saving account gets \(dateFormatter.string(from: nextTerm)) interest on \(estimateInterest)đ. If you close it today, estimated interest will be \(finalInterest)đ (\(freeInterestRate*100)%). Do you want to continue?")
                    
                }
              
            }
          

        }
            close.image = UIImage(named: "done")
            close.backgroundColor = UIColor.white
        let edit = UIContextualAction(style: .normal, title: "Edit"){
                       (action, view, nil) in
           /*  let scr=self.storyboard?.instantiateViewController(withIdentifier: "AddAccumulateView") as! AddAccumulateView
            scr.editMode = true
            scr.editGoal = self.allAccumulate[indexPath.row].goal
            self.navigationController?.pushViewController(scr, animated: true) */
                       
            }
        edit.image = UIImage(named: "edit")
        edit.backgroundColor = UIColor.white
        //Add more
        let addMore = UIContextualAction(style: .normal, title: "Add more"){
                       (action, view, nil) in
           /*  let scr=self.storyboard?.instantiateViewController(withIdentifier: "AddAccumulateView") as! AddAccumulateView
            scr.editMode = true
            scr.editGoal = self.allAccumulate[indexPath.row].goal
            self.navigationController?.pushViewController(scr, animated: true) */
                       
            }
        
        //Withdraw partially
        addMore.image = UIImage(named: "deposit")
       
        //Watch (close saving account)
        let watch = UIContextualAction(style: .normal, title: "Watch"){
                       (action, view, nil) in
        
            }
        edit.image = UIImage(named: "watch")
        edit.backgroundColor = UIColor.white
            let config = UISwipeActionsConfiguration(actions: [addMore, delete, close, edit])
        if indexPath.section == 1{
            let config = UISwipeActionsConfiguration(actions: [watch])
            return config
        }
            return config
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "DetailSavingAccount") as! DetailSavingAccount
        if indexPath.section == 0{
            scr.nameAcc = self.activeAcc[indexPath.row].savingAcc!.name
            scr.savingAcc = self.activeAcc[indexPath.row].savingAcc!
            scr.polysavingAcc = self.activeAcc[indexPath.row]
        }
        else{
            scr.nameAcc = self.closeAcc[indexPath.row].savingAcc!.name
            scr.savingAcc = self.closeAcc[indexPath.row].savingAcc!
            scr.polysavingAcc = self.closeAcc[indexPath.row]
        }

        self.navigationController?.pushViewController(scr, animated: true) 
    }
    
    
}
