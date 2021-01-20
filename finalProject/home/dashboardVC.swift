//
//  dashboardVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import UIKit
import RealmSwift

class dashboardVC: UITableViewController,settingDelegate{
    func changedHideAmountValue(value: Bool) {
        
    }
    
    func changedCurrency(value: Int) {
        
    }
    

    @IBAction func clickSyncData(_ sender: Any) {
        
    }
    let realm = try! Realm()
    var userInfor: User? = nil
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    
    var _balance: Float = 0
    
    func loadAmount(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }
    @IBAction func toNotify(_ sender: Any) {
        let sb = UIStoryboard(name: "other", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "notificationVC") as! notificationVC
        self.navigationController?.pushViewController(dest, animated: false)
    }
    func loadBalance() {
        _balance = 0
        for i in userInfor!.accounts
        {
            if i.type == 0
            {
                _balance += i.cashAcc!.balance
            }
            else if i.type == 1
            {
                _balance += i.bankingAcc!.balance
            }
        }
        print(_balance)
    }
    func loadData()
    {
        userInfor = realm.objects(User.self)[0]
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
    }
    override func viewDidLoad() {
        loadData()
        loadBalance()
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
