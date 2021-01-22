//
//  dashboardVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import UIKit
import RealmSwift
import ProgressHUD
import SCLAlertView

class dashboardVC: UITableViewController,settingDelegate{
    
    @IBOutlet weak var hiMsg: UILabel!
    @IBOutlet weak var totalBalanceTF: UITextField!

    @IBAction func changeHideAmount(_ sender: Any) {
        totalBalanceTF.isSecureTextEntry = !totalBalanceTF.isSecureTextEntry
    }
    
    func changedHideAmountValue(value: Bool) {
        totalBalanceTF.isSecureTextEntry = value
    }
    
    func changedCurrency(value: Int) {
        
    }
    

    @IBAction func clickSyncData(_ sender: Any) {
        ProgressHUD.show("Sync your data...")
        userInfor?.syncData()
        ProgressHUD.dismiss()
        SCLAlertView().showSuccess("Sync data successfully!", subTitle: "")
        return
    }
    let realm = try! Realm()
    var userInfor: User? = nil
    var currency = -1
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    
    var _balance: Float = 0
    
    func loadAmount(value: Float) -> Float
    {
        if currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[currency])
    }
    @IBAction func toNotify(_ sender: Any) {
        let sb = UIStoryboard(name: "other", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "notificationVC") as! notificationVC
        self.navigationController?.pushViewController(dest, animated: false)
    }
    func loadBalance() -> Float{
        var result:Float = 0.0
        for i in userInfor!.accounts
        {
            if i.type == 0
            {
                result += i.cashAcc!.balance
            }
            else if i.type == 1
            {
                result += i.bankingAcc!.balance
            }
            else if i.type == 2
            {
                result += i.savingAcc!.ammount
            }
        }
        return result
    }
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        currency = userInfor!.currency
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        _balance = loadBalance()

    }
    func setData()  {
        hiMsg.text = "Hi \(userInfor?.displayName ?? "")!"
        totalBalanceTF.text = String(loadAmount(value: _balance)) + " \(currencyBase().symbol[currency])"
    }
    override func viewDidLoad() {
        loadData()
        setData()
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
}
