//
//  DepositView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/20/20.
//

import UIKit
import  DropDown
import RealmSwift

class DepositView: UIViewController {

    @IBOutlet weak var txtFee: UITextField!
    @IBOutlet weak var imgAccount: UIImageView!
    @IBOutlet weak var Amount: UILabel!
    @IBOutlet weak var lblNameAccount: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var lblrootName: UILabel!
    @IBOutlet weak var FromAccount: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var TransferFee: UILabel!
    @IBOutlet weak var ToAccount: UILabel!
    var rootAccName: String = ""
    var obj:polyAccount? = nil
    var rootAccount:polyAccount? = nil
    @IBOutlet weak var lblBalance: UITextField!
    override func viewDidLoad() {
        setLanguage()
        super.viewDidLoad()

         self.view.backgroundColor = UIColor(red: 71/255, green: 181/255, blue: 190/255, alpha: 1)
        let pickAccount = UITapGestureRecognizer(target: self, action: #selector(chooseAccount(sender:)))
        accountView.addGestureRecognizer( pickAccount)
    NotificationCenter.default.addObserver(self, selector: #selector(updateAccount), name: .accNotification, object: nil)
        //Display time
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        lblTime.text = dateFormatter.string(from: Date())
        //From Account
        lblrootName.text = rootAccName
        //DEscription
        txtDescription.text = "Desposit to saving account \(rootAccName)"
        
    }
    func setLanguage(){
        FromAccount.setupAutolocalization(withKey: "FromAccount", keyPath: "text")
        Amount.setupAutolocalization(withKey: "Amount", keyPath: "text")
        ToAccount.setupAutolocalization(withKey: "ToAccount", keyPath: "text")
        TransferFee.setupAutolocalization(withKey: "TransferFee", keyPath: "text")
        lblNameAccount.setupAutolocalization(withKey: "ChooseAccount", keyPath: "text")
        
    }
    @IBAction func saveDeposit(_ sender: Any) {
        let realm = try! Realm()
        
       // var accumulateBal:Float = 0.0
        if obj == nil{
            Notice().showAlert(content: "Please input source account")
            return
        }
       
        if lblBalance.text! == "0"{
            Notice().showAlert(content: "Please input balance")
            return
        }
        var accountBal:Float = 0.0
        let balance: Float = Float(lblBalance.text!) as! Float
        let fee = Float(txtFee.text!) as! Float
        let transfer = Transfer()
        try! realm.write {
            transfer.getData(_amount: balance, _type: 4, _descript: "Deposit account", _srcAccount: obj!, _location: "", _srcImg: nil, _date: Date(), _destAccount: rootAccount!, _transferFee: nil )
        }
        transfer.add()
        var accumulateBal:Float = (rootAccount?.accumulate!.addbalance)! + balance
        if obj?.type == 0{
            try! realm.write {
                obj?.cashAcc?.expense(amount: balance)
                rootAccount?.accumulate?.addbalance = accumulateBal
            }
        }
        else {
           try! realm.write {
            obj?.bankingAcc?.expense(amount: balance)
           rootAccount?.accumulate?.addbalance = accumulateBal
       }
            
        }
        self.navigationController?.popViewController(animated: true)
                      
    }
    @objc func updateAccount (notification: Notification){
        obj = notification.object as! polyAccount
        if obj?.type == 0{
            imgAccount.image = UIImage(named: "accountType")
            lblNameAccount.text = obj?.cashAcc?.name
        }
        else{
            imgAccount.image = UIImage(named: (obj?.bankingAcc!.name)!)
            lblNameAccount.text = obj?.bankingAcc?.name
        }
        
        }
    @objc func chooseAccount(sender: UITapGestureRecognizer) {
           let scr=self.storyboard?.instantiateViewController(withIdentifier: "PickAccountView") as! PickAccountView
               
        self.navigationController?.pushViewController(scr, animated: true )
       // self.present(scr, animated: true, completion: nil)
       }
    

}
