//
//  AccumulateAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/14/20.
//

import UIKit
import RealmSwift
import SCLAlertView
class AccumulateAccountView: UIViewController, delegateUpdate {
    func loadTable() {
        loadData()
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    var allAccumulate: [Accumulate] = []
    @IBOutlet weak var lbltotal: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
        self.navigationItem.title = "Accumulate account"
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        loadData()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        loadTable()
    }
    
    func loadData(){
        let realm = try! Realm()
               let accumulate = realm.objects(Accumulate.self)
               allAccumulate = Array(accumulate)
        var total: Float = 0.0
        for bal in accumulate{
            total += bal.addbalance
        }
        lbltotal.text = "\(total)"
    }
}

extension AccumulateAccountView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccumulate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccumulateCell", for: indexPath) as! AddAccumulateCell
        let purBalance = allAccumulate[indexPath.row].balance
        let addBalance = allAccumulate[indexPath.row].addbalance
        if addBalance >= purBalance{
            cell.showComplete(condition: true)
        }
        else {
            cell.showComplete(condition: false)
        }
        let remain = purBalance - addBalance
        cell.lblnowBalance.text = "\(addBalance)"
        cell.lblremain.text = "\(remain)"
        cell.lblTitle.text = allAccumulate[indexPath.row].goal
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
        return "Following"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: "Delete"){
                (action, view, nil) in
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("OK") {
                    let realm = try! Realm()
                    let obj = realm.objects(Accumulate.self).filter("id == '\(self.allAccumulate[indexPath.row].id)'")
                    try! realm.write {
                                realm.delete(obj)
                            }
                    //print(obj.count)
                    self.loadData()
                    tableView.reloadData()
                       
                    }
                alertView.addButton("Exit") {
                           }
                alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this Accumulate will also be removed and cannot be restored ")
                
            }
            delete.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
                UIImage(named: "delete")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))}
            delete.backgroundColor = UIColor.white
        //Deposit choice
        let deposit = UIContextualAction(style: .normal, title: "Deposit"){
                (action, view, nil) in
                 let scr=self.storyboard?.instantiateViewController(withIdentifier: "DepositView") as! DepositView
                              
            scr.rootAccName = self.allAccumulate[indexPath.row].goal
            scr.rootID = self.allAccumulate[indexPath.row].id
            self.navigationController?.pushViewController(scr, animated: true )
                
            }
            deposit.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
            UIImage(named: "deposit")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))}
            deposit.backgroundColor = UIColor.white
        let edit = UIContextualAction(style: .normal, title: "Edit"){
                       (action, view, nil) in
             let scr=self.storyboard?.instantiateViewController(withIdentifier: "AddAccumulateView") as! AddAccumulateView
            scr.editMode = true
            scr.editID = self.allAccumulate[indexPath.row].id
            self.navigationController?.pushViewController(scr, animated: true)
                       
            }
        edit.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30)).image { _ in
        UIImage(named: "edit")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))}
                   edit.backgroundColor = UIColor.white
            let config = UISwipeActionsConfiguration(actions: [delete, deposit, edit])
            return config
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "DetailAccumulate") as! DetailAccumulate
        scr.viewName = allAccumulate[indexPath.row].goal
        scr.accumulate = allAccumulate[indexPath.row]
        self.navigationController?.pushViewController(scr, animated: true)
    }
    
}
