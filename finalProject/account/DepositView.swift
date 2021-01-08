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

    @IBOutlet weak var imgAccount: UIImageView!
    @IBOutlet weak var lblNameAccount: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var lblrootName: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    var rootAccName: String = ""
    var rootID: Int = 0
    var obj:polyAccount? = nil
    @IBOutlet weak var lblBalance: UITextField!
    override func viewDidLoad() {
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

    @IBAction func saveDeposit(_ sender: Any) {
        let realm = try! Realm()
        let accumulate = realm.objects(Accumulate.self).filter("id == \(self.rootID)").first
       // var accumulateBal:Float = 0.0
        var accountBal:Float = 0.0
        let balance: Float = Float(lblBalance.text!) as! Float
        //let accountBal
        var accumulateBal:Float = accumulate!.addbalance + balance
        //print(accumulateBal)
        if obj?.type == 0{
           // print(obj!.name)
            try! realm.write {
                obj?.cashAcc?.expense(amount: balance)
                accumulate!.addbalance = accumulateBal
            }
        }
        else {
           try! realm.write {
            obj?.bankingAcc?.expense(amount: balance)
           accumulate!.addbalance = accumulateBal
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
    @IBAction func chooseType(_ sender: UIButton) {
               let dropDown = DropDown()

               // The view to which the drop down will appear on
               dropDown.anchorView = sender // UIView or UIBarButtonItem

               // The list of items to display. Can be changed dynamically
               dropDown.dataSource = ["Income","Transfer"]

               /*** IMPORTANT PART FOR CUSTOM CELLS ***/
               dropDown.cellNib = UINib(nibName: "typeRecord", bundle: nil)

               dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                  guard let cell = cell as? typeRecord else { return }

                  // Setup your custom UI components
                  cell.logo.image = UIImage(named: "home")
               }
        
               dropDown.show()
    }

}
