//
//  AccumulateAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/14/20.
//

import UIKit
import RealmSwift
import SCLAlertView
import DropDown
class AccumulateAccountView: UIViewController, delegateUpdate {
    func loadTable() {
        loadData()
        tableView.reloadData()
    }

    var isVietnamese = false
    @IBOutlet weak var totalSave: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var allAccumulate: [polyAccount] = []
    @IBOutlet weak var lbltotal: UILabel!
    override func viewDidLoad() {
        
        let realm = try! Realm()
        let lang = realm.objects(User.self).first?.isVietnamese
        if lang == true{
            isVietnamese = true
        }
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
        self.navigationItem.title = "Accumulate account"
        if isVietnamese == true{
            self.navigationItem.title = "Tài khoản tích luỹ"
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        loadData()
        setLanguage()
       
    }
    @objc func showDropDown(sender: UIButton){
        let buttonTag = sender.tag
    }
    override func viewWillAppear(_ animated: Bool) {
        loadTable()
    }
    
    func loadData(){
        let realm = try! Realm()
        let accumulate = realm.objects(polyAccount.self).filter("type == 3")
               allAccumulate = Array(accumulate)
        var total: Float = 0.0
        for bal in accumulate{
            total += bal.accumulate!.addbalance
        }
        lbltotal.text = "\(total)$"
        
    }
    func setLanguage(){
        totalSave.setupAutolocalization(withKey: "TotalSave", keyPath: "text")
    
    }
}
//
class ClosureSleeve {
  let closure: () -> ()

  init(attachTo: AnyObject, closure: @escaping () -> ()) {
    self.closure = closure
    objc_setAssociatedObject(attachTo, "[\(arc4random())]", self,.OBJC_ASSOCIATION_RETAIN)
}

@objc func invoke() {
   closure()
 }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
  let sleeve = ClosureSleeve(attachTo: self, closure: action)
 addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
 }
}
//
extension AccumulateAccountView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccumulate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccumulateCell", for: indexPath) as! AddAccumulateCell
        let purBalance = allAccumulate[indexPath.row].accumulate!.balance
        let addBalance = allAccumulate[indexPath.row].accumulate!.addbalance
        if addBalance >= purBalance{
            cell.showComplete(condition: true)
        }
        else {
            cell.showComplete(condition: false)
        }
        cell.btnOption.addAction {
            print(indexPath.row)
            let dropDown = DropDown()
            dropDown.anchorView = cell.btnOption
            dropDown.dataSource = ["Edit", "Deposit", "Delete"]
            dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)
            dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard let cell = cell as? typeRecord else { return }
                
                // Setup your custom UI components
                if index == 0
                {
                    cell.logo.image = UIImage(named: "edit")
                }
                else if index == 1
                {
                    cell.logo.image = UIImage(named: "deposit")
                }
                else{
                    cell.logo.image = UIImage(named: "delete")
                }
            }
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
                if index == 0
                {
                    let scr=self?.storyboard?.instantiateViewController(withIdentifier: "AddAccumulateView") as! AddAccumulateView
                    scr.editMode = true
                    scr.editGoal = (self?.allAccumulate[indexPath.row].accumulate!.goal)!
                    self?.navigationController?.pushViewController(scr, animated: true)
                }
                else if index == 1
                {
                    let scr = self?.storyboard?.instantiateViewController(withIdentifier: "DepositView") as! DepositView
                    
                    scr.rootAccName = (self?.allAccumulate[indexPath.row].accumulate!.goal)!
                    scr.rootAccount = self!.allAccumulate[indexPath.row]
                    self?.navigationController?.pushViewController(scr, animated: true )
                }
                else{
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("OK") {
                        let realm = try! Realm()
                        let obj = realm.objects(polyAccount.self).filter("type  == 3")
                        let transfer = realm.objects(polyRecord.self).filter("type == 4")
                        for i in transfer{
                         
                         if i.transfer?.srcAccount?.getname() == self!.allAccumulate[indexPath.row].accumulate?.goal{
                                i.del()
                            }
                         else if i.transfer?.destinationAccount?.getname() == self!.allAccumulate[indexPath.row].accumulate?.goal{
                                i.del()
                            }
                        }
                        for del in obj{
                            del.accumulate?.goal == self!.allAccumulate[indexPath.row].accumulate?.goal
                            del.del()
                            break;
                        }
                       
                        self!.loadData()
                        tableView.reloadData()
                           
                        }
                    alertView.addButton("Exit") {
                               }
                    alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this Accumulate will also be removed and cannot be restored ")
               }
            }
            dropDown.show()
        }
        let remain = purBalance - addBalance
        cell.lblnowBalance.text = "\(addBalance)"
        cell.lblremain.text = "\(remain)"
        cell.lblTitle.text = allAccumulate[indexPath.row].accumulate?.goal
        cell.lblstartBalance.text = "\(purBalance)"
        cell.progressView.progress = addBalance/purBalance
        cell.backgroundView = UIImageView(image: UIImage(named: "row"))
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor(red: 153/255, green: 219/255, blue: 221/255, alpha: 1).cgColor
           return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isVietnamese == true{
            return "Đang theo dõi"
        }
        return "Following"
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "DetailAccumulate") as! DetailAccumulate
        scr.viewName = allAccumulate[indexPath.row].accumulate!.goal
        scr.accumulate = allAccumulate[indexPath.row]
        self.navigationController?.pushViewController(scr, animated: true)
    }
    
}
