//
//  ViewController.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift
import SCLAlertView

class homeVC: UIViewController {
    let realm = try! Realm()
    var userInfor: User? = nil
    
    @IBOutlet weak var totalBalance: UILabel!
    
    @IBOutlet weak var income: UILabel!
    
    @IBOutlet weak var expense: UILabel!
    
    var _balance: Float = 0
    var _income: Float = 0
    var _expense: Float = 0
    override var shouldAutorotate: Bool{
        get{
            return false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func loadData() {
        _balance = 0
        _income = 0
        _expense = 0
        let temp = realm.objects(User.self)
        if temp.isEmpty
        {
          SCLAlertView().showError("User error!", subTitle: "")
//            try! realm.write{
//            realm.add(User())
//            }
            return
        }
        else
        {
            userInfor = temp[0]
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
            for i in userInfor!.records
            {
                if i.isDeleted == true
                {
                    continue
                }
                switch i.type {
                case 0:
                    _expense += i.expense!.amount
                case 1:
                    _income += i.income!.amount
                case 2:
                    _expense += i.lend!.amount
                case 3:
                    _income += i.borrow!.amount
                case 4:
                    print("do nothing")
                default:
                    print("do nothing")
                }
            }
            totalBalance.text = String(_balance)
            income.text = String(_income) + "$"
            expense.text = String(_expense) + "$"
        }
    }
    @IBAction func toNotify(_ sender: Any) {
        let sb = UIStoryboard(name: "editRecord", bundle: nil)
        let dest = sb.instantiateViewController(identifier: "notificationVC") as! notificationVC
        self.navigationController?.pushViewController(dest, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(false)
    }

}

