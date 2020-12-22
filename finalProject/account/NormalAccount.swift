//
//  NormalAccount.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/1/20.
//

import UIKit
import RealmSwift
import SCLAlertView
enum AccountType{
    case cash, banking
}
class displayAccout{
    var name: String = ""
    var balance: Float = 0
    var image: UIImage = UIImage()
    var type: AccountType = .cash
    init(name: String, balance: Float, img: UIImage, type: AccountType) {
        self.name = name
        self.balance = balance
        self.image = img
        self.type = type
    }
}
class NormalAccount: UIViewController, updateDataDelegate {
    func updateTable() {
        loadData()
        var balance: Float = 0.0
        for obj in activeAccount{
            balance += obj.balance
        }
        lblBalance.text = String(balance)
        lblCurrency.text = ".đ"
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        updateTable()
    }
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    var iconImg = ["active","block"]
    var titleLbl = ["Active account", "Blocked account"]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    var activeAccount: [displayAccout] = []
    var blockedAccount: [displayAccout] = []
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var navigationBar: UINavigationItem!
    var backgroundImage: UIImageView!
       override func viewDidLoad() {
           super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 123/255, blue: 164/255, alpha: 1)
       // tableView.isEditing = true
        let back = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(exitTapped))
               navigationBar.rightBarButtonItem = addBtn
               navigationBar.title = "Account"
               navigationBar.leftBarButtonItem = back
        loadData()
        var balance: Float = 0.0
        for obj in activeAccount{
            balance += obj.balance
        }
        lblBalance.text = "\(balance)"
        lblCurrency.text = ".đ"
        //NavBar background color
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 123/255, blue: 164/255, alpha: 1)
       }
    // Load active and blocked account
    func loadData(){
        let realm = try! Realm()
        let cashAccount = realm.objects(Account.self)
        let bankingAccount = realm.objects(BankingAccount.self)
        activeAccount = []
        blockedAccount = []
        for obj in cashAccount{

            let name = obj.name
            let balance = obj.balance
            if obj.active == true{
                activeAccount.append(displayAccout(name: name, balance: balance,img: UIImage(named: "Cash")!, type: AccountType.cash))
            }
            else{
                blockedAccount.append(displayAccout(name: name, balance: balance, img: UIImage(named: "Cash")!, type: AccountType.cash))
            }
        }
        for obj in bankingAccount{
            let name = obj.name
            let balance = obj.balance
            let image = UIImage(named: obj.bankImg)!
            if obj.active == true{
                activeAccount.append(displayAccout(name: name, balance: balance, img: image, type: AccountType.banking))
            }
            else{
                blockedAccount.append(displayAccout(name: name, balance: balance, img: image, type: AccountType.banking))
            }
        }
    }
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddAccountSegue" {
        let secondVC: AddAccountView = segue.destination as! AddAccountView
        secondVC.delegate = self
    }
    }
 /*   override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           self.backgroundImage.frame = self.view.bounds
           // let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
       }
   @objc func addTapped(){
        let scr=self.storyboard?.instantiateViewController(withIdentifier: "AddAccountView") as! AddAccountView
                   self.present(scr, animated: true, completion: nil)
    }*/
    @objc func exitTapped(){
          dismiss(animated: true, completion: nil)
       }
}
extension NormalAccount: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Being used"
        }
        else {
            return "Blocked"
        }
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
            cell.lblName.text = activeAccount[indexPath.row].name
            cell.lblMoney.text = "\(activeAccount[indexPath.row].balance)"
            cell.imgIcon.image = activeAccount[indexPath.row].image
        }
        else if indexPath.section == 1{
            cell.lblName.text = blockedAccount[indexPath.row].name
            cell.lblMoney.text = "\(blockedAccount[indexPath.row].balance)"
             cell.imgIcon.image = blockedAccount[indexPath.row].image
        }
        cell.backgroundView = UIImageView(image: UIImage(named: "row"))
        cell.layer.borderWidth = 5
        cell.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    }
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
        return 60
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
                if indexPath.section == 0{
                    let type = self.activeAccount[indexPath.row].type
                    if type == AccountType.cash{
                        let obj = realm.objects(Account.self).filter("name == '\(self.activeAccount[indexPath.row].name)'")
                        try! realm.write {
                            realm.delete(obj)
                        }
                    }
                    else if type == AccountType.banking{
                        let obj = realm.objects(BankingAccount.self).filter("name == '\(self.activeAccount[indexPath.row].name)'")
                        try! realm.write {
                            realm.delete(obj)
                        }
                    }
                    
                }
                else if indexPath.section == 1{
                    let type = self.blockedAccount[indexPath.row].type
                    if type == AccountType.cash{
                        let obj = realm.objects(Account.self).filter("name == '\(self.blockedAccount[indexPath.row].name)'")
                        try! realm.write {
                            realm.delete(obj)
                        }
                    }
                    else if type == AccountType.banking{
                        let obj = realm.objects(BankingAccount.self).filter("name == '\(self.blockedAccount[indexPath.row].name)'")
                        try! realm.write {
                            realm.delete(obj)
                        }
                    }
                }
                self.loadData()
                var balance: Float = 0.0
                for obj in self.activeAccount{
                           balance += obj.balance
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
                let type = self.activeAccount[indexPath.row].type
                if type == AccountType.cash{
                    let obj = realm.objects(Account.self).filter("name == '\(self.activeAccount[indexPath.row].name)'").first
                    try! realm.write {
                        obj!.active = !obj!.active
                    }
                }
                else if type == AccountType.banking{
                    let obj = realm.objects(BankingAccount.self).filter("name == '\(self.activeAccount[indexPath.row].name)'").first

                    try! realm.write {
                        obj!.active = !obj!.active
                    }
                }
                
            }
            else if indexPath.section == 1{
                let type = self.blockedAccount[indexPath.row].type
                if type == AccountType.cash{
                    let obj = realm.objects(Account.self).filter("name == '\(self.blockedAccount[indexPath.row].name)'").first
                    
                    try! realm.write {
                        obj!.active = !obj!.active
                    }
                }
                else if type == AccountType.banking{
                    let obj = realm.objects(BankingAccount.self).filter("name == '\(self.blockedAccount[indexPath.row].name)'").first
                    try! realm.write {
                        obj!.active = !obj!.active
                    }
                }
            }
            self.loadData()
            var balance: Float = 0.0
            for obj in self.activeAccount{
                       balance += obj.balance
                   }
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
            let realm = try! Realm()
             if indexPath.section == 0{
                 let type = self.activeAccount[indexPath.row].type
                 if type == AccountType.cash{
                    let obj = realm.objects(Account.self).filter("name == '\(self.activeAccount[indexPath.row].name)'").first
                    scr.nameAccount = obj!.name
                    scr.descAccount = obj!.descrip
                    scr.currency = obj!.currency
                    scr.account = "Cash"
                    scr.editMode = true
                    scr.nameEdit = obj!.name
                    scr.active = true
                    scr.balance = "\(obj!.balance)"
            
                 }
                 else if type == AccountType.banking{
                    let obj = realm.objects(BankingAccount.self).filter("name == '\(self.activeAccount[indexPath.row].name)'").first
                    scr.nameAccount = obj!.name
                    scr.descAccount = obj!.descrip
                    scr.currency = obj!.currency
                    scr.account = "Banking Account"
                    scr.bankName = obj!.bankName
                    scr.editMode = true
                    scr.nameEdit = obj!.name
                    scr.active = true
                    scr.balance = "\(obj!.balance)"
                 }
                 
             }
             else if indexPath.section == 1{
                 let type = self.blockedAccount[indexPath.row].type
                 if type == AccountType.cash{
                    let obj = realm.objects(Account.self).filter("name == '\(self.blockedAccount[indexPath.row].name)'").first
                    scr.nameAccount = obj!.name
                    scr.descAccount = obj!.descrip
                    scr.currency = obj!.currency
                    scr.account = "Cash"
                    scr.editMode = true
                    scr.nameEdit = obj!.name
                    scr.active = false
                    scr.balance = "\(obj!.balance)"
                 }
                 else if type == AccountType.banking{
                    let obj = realm.objects(BankingAccount.self).filter("name == '\(self.blockedAccount[indexPath.row].name)'").first
                    scr.nameAccount = obj!.name
                    scr.descAccount = obj!.descrip
                    scr.currency = obj!.currency
                    scr.account = "Banking Account"
                    scr.bankName = obj!.bankName
                    scr.editMode = true
                    scr.nameEdit = obj!.name
                    scr.active = false
                    scr.balance = "\(obj!.balance)"
                 }
             }
                  //self.present(scr, animated: true, completion: nil)
            self.navigationController!.pushViewController(scr, animated: true)
        }
        edit.image = UIImage(named:"edit");
            
           
        
        
        stop.backgroundColor = UIColor.white
       
        let config = UISwipeActionsConfiguration(actions: [delete,stop,edit])

        return config
    }
}
