//
//  NormalAccount.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/1/20.
//

import UIKit
import RealmSwift
import SCLAlertView

class NormalAccount: UIViewController, updateDataDelegate {
    func updateTable() {
        loadData()
        var balance: Float = 0.0
        for obj in activeAccount{
            if obj.type == 0{
                balance += obj.cashAcc!.balance
            }
            else{
                balance += obj.bankingAcc!.balance
            }
            
        }
        lblBalance.text = String(balance)
        lblCurrency.text = ".$"
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateTable()
    }
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    var iconImg = ["active","block"]
    var titleLbl = ["Active account", "Closed account"]
    @IBOutlet weak var tableView: UITableView!
    var activeAccount: [polyAccount] = []
    var blockedAccount: [polyAccount] = []
       override func viewDidLoad() {
           super.viewDidLoad()
       self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
               // Do any additional setup after loading the view.
        self.navigationItem.title = "Account"
        self.navigationController?.navigationBar.titleTextAttributes = [
                   .foregroundColor: UIColor.white,
                   .font: UIFont(name: "MarkerFelt-Thin", size: 20)!]
        loadData()
        var balance: Float = 0.0
        for obj in activeAccount{
            if obj.type == 0{
                 balance += obj.cashAcc!.balance
             }
             else{
                 balance += obj.bankingAcc!.balance
             }
        }
        lblBalance.text = "\(balance)"
        lblCurrency.text = ".đ"
        //NavBar background color
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 123/255, blue: 164/255, alpha: 1)
       }
    // Load active and blocked account
    func loadData(){
        let realm = try! Realm()
        let account = realm.objects(polyAccount.self)
        activeAccount = []
        blockedAccount = []
        for obj in account{
            
            if obj.type == 0{
                if obj.cashAcc?.active == true{
                    activeAccount.append(obj)
                }
                else{
                    blockedAccount.append(obj)
                }
            }
            else if obj.type == 1{
                
                if obj.bankingAcc?.active == true{
                    activeAccount.append(obj)
                }
                else{
                    blockedAccount.append(obj)
                }
            }
        }

        
    }
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddAccountSegue" {
        let secondVC: AddAccountView = segue.destination as! AddAccountView
        secondVC.delegate = self
    }
    }

    @objc func exitTapped(){
          dismiss(animated: true, completion: nil)
       }
}
extension NormalAccount: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleLbl[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return activeAccount.count
        }
        else if section == 1{
            return blockedAccount.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "AllNormalAccountCell", for: indexPath) as! AllNormalAccountCell
        
        if indexPath.section == 0{
            let obj = activeAccount[indexPath.row]
            if obj.type == 0{
                cell.lblName.text = obj.cashAcc?.name
                cell.lblMoney.text = "\(obj.cashAcc?.balance as! Float)"
                cell.imgIcon.image = UIImage(named:"accountType")
            }
            else if obj.type == 1{
                cell.lblName.text = obj.bankingAcc?.name
                cell.lblMoney.text = "\(obj.bankingAcc?.balance as! Float)"
                cell.imgIcon.image = UIImage(named: obj.bankingAcc!.name)
            }
           
        }
        else if indexPath.section == 1{
            let obj1 = blockedAccount[indexPath.row]
            if obj1.type == 0{
               cell.lblName.text = obj1.cashAcc?.name
                cell.lblMoney.text = "\(obj1.cashAcc?.balance as! Float)"
               cell.imgIcon.image = UIImage(named:"accountType")
           }
            else if obj1.type == 1{
               cell.lblName.text = obj1.bankingAcc?.name
                cell.lblMoney.text = "\(obj1.bankingAcc?.balance as! Float)"
                cell.imgIcon.image = UIImage(named: obj1.bankingAcc!.name)
           }
        }
        cell.backgroundView = UIImageView(image: UIImage(named: "row"))
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

   /* func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 65/255, green: 146/255, blue: 96/255, alpha: 0.5)
        let image = UIImageView(image: UIImage(named: iconImg[section]))
        image.frame = CGRect(x: 5, y: 5, width: 35, height: 35)
        view.addSubview(image)
        let label = UILabel()
        label.text = titleLbl[section]
        label.frame = CGRect(x: 70, y: 5, width: 150, height: 50)
        view.addSubview(label)
        return view
    }*/
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if activeAccount.count == 0{
            if section == 0{
                return 0
            }
        }
        else if blockedAccount.count == 0{
            if section == 1{
                return 0
            }
        }
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "DetailAccount") as! DetailAccount
        if indexPath.section == 0{
            scr.Acc = self.activeAccount[indexPath.row]
        }
        else{
            scr.Acc = self.blockedAccount[indexPath.row]
        }
        self.navigationController!.pushViewController(scr, animated: true)
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
                var obj: polyAccount
   
                if indexPath.section == 0{
                  let account = Array(realm.objects(polyAccount.self).filter("type == 2"))
                //Xoa account, xoá record liên quan
                let record = Array(realm.objects(polyRecord.self))
                for tempRecord in record{
                    let srcAcc = tempRecord.srcAccount()
                    if srcAcc.getname() == self.activeAccount[indexPath.row].cashAcc!.name{
                        tempRecord.del()
                    }
                    else if srcAcc.getname() == self.activeAccount[indexPath.row].bankingAcc!.name{
                        tempRecord.del()
                    }
                }
               
                //Xoá account, xoá saving account liên quan
                  for acc in account{
                      let sav = acc.savingAcc
                      if sav!.state == false{
                          if sav?.srcAccount?.type == 0{
                              if sav?.srcAccount?.cashAcc?.id == self.activeAccount[indexPath.row].cashAcc?.id{
                                  acc.del()
                              }
                          }
                          else{
                              if sav?.srcAccount?.bankingAcc?.id == self.activeAccount[indexPath.row].bankingAcc?.id{
                                  acc.del()
                              }
                          }
                      }
                  }
                    obj = self.activeAccount[indexPath.row]
                    obj.del()
                
                }
                else if indexPath.section == 1{
                   let account = Array(realm.objects(polyAccount.self).filter("type == 2"))
                    //Xoa account, xoá record liên quan
                    let record = Array(realm.objects(polyRecord.self))
                    for tempRecord in record{
                        let srcAcc = tempRecord.srcAccount()
                        if srcAcc.getname() == self.blockedAccount[indexPath.row].cashAcc!.name{
                            tempRecord.del()
                        }
                        else if srcAcc.getname() == self.blockedAccount[indexPath.row].bankingAcc!.name{
                            tempRecord.del()
                        }
                    }
                   
                    //Xoá account, xoá saving account liên quan
                      for acc in account{
                          let sav = acc.savingAcc
                          if sav!.state == false{
                              if sav?.srcAccount?.type == 0{
                                  if sav?.srcAccount?.cashAcc?.id == self.blockedAccount[indexPath.row].cashAcc?.id{
                                      acc.del()
                                  }
                              }
                              else{
                                  if sav?.srcAccount?.bankingAcc?.id == self.blockedAccount[indexPath.row].bankingAcc?.id{
                                      acc.del()
                                  }
                              }
                          }
                      }
                        obj = self.blockedAccount[indexPath.row]
                        obj.del()
                }

                
                self.loadData()
                var balance: Float = 0.0
                for obj in self.activeAccount{
                    if obj.type == 0{
                        balance += obj.cashAcc!.balance
                    }
                    else{
                        balance += obj.bankingAcc!.balance
                    }
                }
                self.lblBalance.text = "\(balance)"
                tableView.reloadData()

            }
            alertView.addButton("Exit") {
                print("Exit")
                       }
            alertView.showError("Warning", subTitle: "If you delete this Acocunt, all Record in this Account will also be removed and cannot be restored ")
            
        }
        delete.image = UIImage(named: "delete")
        delete.backgroundColor = UIColor.white
    
        let stop = UIContextualAction(style: .normal, title: "Stop"){
            (action, view, nil) in
            let realm = try! Realm()
            if indexPath.section == 0{
                let obj = self.activeAccount[indexPath.row]
                if obj.type == 0{
                    try! realm.write{
                        obj.cashAcc?.active = !obj.cashAcc!.active
                    }
                    
                }
                else{
                    try! realm.write{
                        obj.bankingAcc?.active = !obj.bankingAcc!.active
                    }
                }
                
            }
            else if indexPath.section == 1{
                let obj = self.blockedAccount[indexPath.row]
                if obj.type == 0{
                    try! realm.write{
                        obj.cashAcc?.active = !obj.cashAcc!.active
                    }
                    
                }
                else{
                    try! realm.write{
                        obj.bankingAcc?.active = !obj.bankingAcc!.active
                    }
                }
            }
            self.loadData()
            var balance: Float = 0.0
            for obj in self.activeAccount{
               if obj.type == 0{
                   balance += obj.cashAcc!.balance
               }
               else{
                   balance += obj.bankingAcc!.balance
               }                   }
                self.lblBalance.text = "\(balance)"
                tableView.reloadData()
            }
        if indexPath.section == 0{
            stop.image = UIImage(named: "stop")
        }
        else if indexPath.section == 1{
            stop.image = UIImage(named: "play")
        }
        
        stop.backgroundColor = UIColor.white
// Edit button
        let edit = UIContextualAction(style: .normal, title: "Edit"){
            (action, view, nil) in
            let scr=self.storyboard?.instantiateViewController(withIdentifier: "AddAccountView") as! AddAccountView
            if indexPath.section == 0{
                scr.editAcc = self.activeAccount[indexPath.row]
            }
            else{
                scr.editAcc = self.blockedAccount[indexPath.row]
            }
            scr.editMode = true
                  //self.present(scr, animated: true, completion: nil)
            self.navigationController!.pushViewController(scr, animated: true)
        }
        edit.image = UIImage(named:"edit");
        stop.backgroundColor = UIColor.white
        let config = UISwipeActionsConfiguration(actions: [delete,stop,edit])

        return config
    }
}
