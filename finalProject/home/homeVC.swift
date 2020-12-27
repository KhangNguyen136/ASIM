//
//  ViewController.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/22/20.
//

import UIKit
import RealmSwift

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
            userInfor = User()
            try! realm.write{
                realm.add(userInfor!)
            }
        }
        else
        {
            userInfor = temp[0]
            for i in userInfor!.accounts
            {
                if i.type == 1
                {
                    _balance += i.cashAcc!.balance
                }
                else
                {
                    _balance += i.bankingAcc!.balance
                }
            }
            for i in userInfor!.records
            {
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
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        super.viewWillAppear(false)
    }

}

