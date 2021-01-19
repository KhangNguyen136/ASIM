//
//  ViewController.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift
import SCLAlertView

class homeVC: UIViewController,settingDelegate {
    
    
    let realm = try! Realm()
    var userInfor: User? = nil
    var setting: settingObserve? = nil
    var settingObser: settingObserver? = nil
    func loadAmount(value: Float) -> Float
    {
        if userInfor?.currency == 0
        {
            return value
        }
        return value * Float(currencyBase().valueBaseDolar[userInfor!.currency])
    }
    func changedHideAmountValue(value: Bool) {
        print("Hide amount changed.")
        if value == true
        {
            totalBalance.text = "******** " + currencyBase().symbol[userInfor!.currency]
        }
        else
        {
            totalBalance.text = String(loadAmount(value: _balance)) + " " + currencyBase().symbol[userInfor!.currency]
        }
    }
    
    func changedCurrency(value: Int) {
        print("Currency changed.")
        totalBalance.text = String(loadAmount(value: _balance)) + " " + currencyBase().symbol[userInfor!.currency]
        income.text = String(loadAmount(value: _income)) + " " + currencyBase().symbol[userInfor!.currency]
        expense.text = String(loadAmount(value: _expense)) + " " + currencyBase().symbol[userInfor!.currency]
    }
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
        userInfor = realm.objects(User.self)[0]
        setting = settingObserve(user: userInfor!)
        settingObser = settingObserver(object: setting!)
        setting?.delegate = self
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func loadData() {
        _balance = 0
        _income = 0
        _expense = 0
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
                continue
            default:
                let temp = i.adjustment
                if temp?.subType == 0
                {
                    _expense += temp!.different
                }
                else
                {
                    _income += temp!.different
                }
            }
            totalBalance.text = String(loadAmount(value: _balance)) + " " + currencyBase().symbol[userInfor!.currency]
            income.text = String(loadAmount(value: _income)) + " " + currencyBase().symbol[userInfor!.currency]
            expense.text = String(loadAmount(value: _expense)) + " " + currencyBase().symbol[userInfor!.currency]
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

