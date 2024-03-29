//
//  selectAccountVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/29/20.
//

import UIKit
import RealmSwift
import SCLAlertView

class selectAccountVC: UIViewController, settingDelegate {
    var delegate: selectAccountDelegate? = nil
    var delegate1: selectDestinationAccountDelegate? = nil
    var dataSource: [polyAccount] = []
    let realm = try! Realm()
    @IBOutlet weak var listTV: UITableView!
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    var isHideAmount = false
    var currency = 0
    func changedHideAmountValue(value: Bool) {
        isHideAmount = value
        listTV.reloadData()
    }
    func changedCurrency(value: Int) {
        currency = value
        listTV.reloadData()
    }
    func loadData()  {
        let userInfor = realm.objects(User.self)[0]
        setting = settingObserve(user: userInfor)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        isHideAmount = userInfor.isHideAmount
        currency = userInfor.currency

        if delegate1 != nil{
            self.navigationItem.title = "Select destination account"
        }
        let temp = userInfor.accounts
        for i in temp
        {
            if i.isDeleted == true
            {
                continue
            }
            switch i.type {
            case 0:
                if i.cashAcc?.active == true
                {
                    dataSource.append(i)
                }
            case 1:
                if i.bankingAcc?.active == true
                {
                    dataSource.append(i)
                }
            default:
                continue
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
        cell.getData(acc: dataSource[indexPath.row],currency: currency, hideAmount: isHideAmount)

    return cell
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let temp = dataSource[indexPath.row]
        var nameStr = ""
        if temp.type == 0
        {
            nameStr = temp.cashAcc!.name
        }
        else if temp.type == 1
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
