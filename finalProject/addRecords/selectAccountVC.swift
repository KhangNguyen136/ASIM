//
//  selectAccountVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/29/20.
//

import UIKit
import RealmSwift
import SCLAlertView

class selectAccountVC: UIViewController {
    var delegate: selectAccountDelegate? = nil
    var delegate1: selectDestinationAccountDelegate? = nil
    var dataSource: [polyAccount] = []
    let realm = try! Realm()
    @IBOutlet weak var listTV: UITableView!
    
    func loadData()  {
        if delegate1 != nil{
            self.navigationItem.title = "Select destination account"
        }
        let temp = realm.objects(polyAccount.self)
        for i in temp
        {
            if i.type == 1 && i.cashAcc?.active == true && i.isDeleted == false
            {
                dataSource.append(i)
            }
            else if i.bankingAcc?.active == true
            {
                dataSource.append(i)
            }
        }
        if dataSource.isEmpty
        {
            SCLAlertView().showWarning("No account active", subTitle: "Add or active account to continue!")
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    override func viewDidLoad() {
        loadData()
        listTV.register(accountCell.self, forCellReuseIdentifier: "accountCell")
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

}
extension selectAccountVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: accountCell = listTV.dequeueReusableCell(withIdentifier: "accountRow", for: indexPath) as! accountCell
        cell.getData(acc: dataSource[indexPath.row])

    return cell
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = dataSource[indexPath.row]
        var nameStr = ""
        if temp.type == 1
        {
            nameStr = temp.cashAcc!.name
        }
        else
        {
            nameStr = temp.bankingAcc!.name
        }
        if delegate != nil
        {
        delegate?.didSelectAccount(temp: dataSource[indexPath.row],name: nameStr)
        self.navigationController?.popViewController(animated: false)
            return
        }
        if delegate1 != nil
        {
            delegate1?.didSelectDestAccount(temp: dataSource[indexPath.row], name: nameStr)
            self.navigationController?.popViewController(animated: false)
                return
        }
    }
}
