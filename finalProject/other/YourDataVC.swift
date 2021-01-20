//
//  dataVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/26/20.
//

import UIKit
import RealmSwift
import FirebaseDatabase
import ProgressHUD
import SCLAlertView

struct accountTempClass: Codable{
    let type: Int
    let id : String
    let name: String
    let balance: Float
    let currency: String
    let active: Bool
    let bankName: String
}

class yourDataVC: UITableViewController {

    let realm = try! Realm()
    var userInfor: User? = nil
    var ref = Database.database().reference()

    @IBOutlet weak var lastSync: UIButton!
    func getUser()  {
        let temp = realm.objects(User.self)
        if temp.isEmpty
        {
            return
        }
        else
        {
            userInfor = temp[0]
        }
        getLastSync()
    }
    func getLastSync()
    {
        if userInfor?.lastSync != nil
        {
            let formatter = DateFormatter()
            formatter.dateFormat = userInfor?.dateFormat
            let tempDate = "Last sync: " +  formatter.string(from: (userInfor?.lastSync)!) + " " + (userInfor?.lastSync?.timeString())!
            lastSync.setTitle(tempDate , for: .normal)
        }
        else
        {
            lastSync.setTitle("", for: .normal)
        }
    }
    
    typealias connectionStt = (Bool) -> Void
    func checkConnection(comletionHanlder: @escaping connectionStt)
    {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observeSingleEvent(of: .value, with: { snapshot in
          if snapshot.value as? Bool ?? false {
            comletionHanlder(true)
            return
          } else {
            comletionHanlder(false)
            return
          }
        })
    }
    @IBAction func clickSyncData(_ sender: Any) {
        checkConnection{ [self] connectionStt in
            if connectionStt == false
            {
                SCLAlertView().showError("Network error", subTitle: "Check your connection and try again.")
                return
            }
            else
            {
            syncData()
            }
        }
    }
    func syncData(){
        ProgressHUD.show("Sync your data...")
        userInfor?.syncData()
        print("Synced!")
        ProgressHUD.dismiss()
        SCLAlertView().showSuccess("Sync data successfully!", subTitle: "")
        getLastSync()
        return
    }
    
    @IBAction func clickReloadData(_ sender: Any) {
        checkConnection{ connectionStt in
            if connectionStt == false
            {
                SCLAlertView().showError("Network error", subTitle: "Check your connection and try again!")
                return
            }
            else
            {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let msg = SCLAlertView(appearance: appearance)
            msg.addButton("No", action: {
                print("Cancel reload data.")
                return
            })
            msg.addButton("Yes", action: { [self] in
                reloadDataFromFirebase()
            })
            msg.showWarning("Reload data will delete all current data.", subTitle: "Your data will be replaced by data you had been sync last time. Do you want to continue?")
            }
        }
    }
    func deleteLocalData(){
        print("Begin delete local data...")
        try! realm.write {
//            let tempUsername = userInfor!.username
//            realm.deleteAll()
//            userInfor = User()
//            userInfor?.username = tempUsername
//            realm.add(userInfor!)
            for i in userInfor!.accounts
            {
                switch i.type {
                case 0:
                    realm.delete(i.cashAcc!)
                case 1:
                    realm.delete(i.bankingAcc!)
                default:
                    realm.delete(i.savingAcc!)
                }
                realm.delete(i)
            }
            for i in userInfor!.records
            {
                switch i.type {
                case 0:
                    realm.delete(i.expense!)
                case 1:
                    realm.delete(i.income!)
                case 2:
                    realm.delete(i.lend!)
                case 3:
                    realm.delete(i.borrow!)
                case 4:
                    realm.delete(i.transfer!)
                default:
                    realm.delete(i.adjustment!)
                }
                realm.delete(i)
            }
            userInfor!.persons.removeAll()
            userInfor!.locations.removeAll()
            userInfor!.events.removeAll()
        }
        print("Deleted local data.")
    }
    func reloadDataFromFirebase(){
        ProgressHUD.show("Reloading your data from database online...")
        deleteLocalData()
        userInfor?.reloadData{ [self] result in
            print(result)
            if result == true
            {
                reloadView()
                SCLAlertView().showSuccess("Reload data successfully", subTitle: "")
            }
            else
            {
                SCLAlertView().showError("Reload data fail", subTitle: "There is no data in server!")
            }
            ProgressHUD.dismiss()
            print("End reload data from firebase.")
        }
    }
    @IBAction func clickResetData(_ sender: Any) {
        checkConnection{ connectionStt in
                if connectionStt == false
                {
                    SCLAlertView().showError("Network error", subTitle: "Check your connection and try again.")
                    return
                }
                else
                {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let msg = SCLAlertView(appearance: appearance)
                    msg.addButton("No", action: {
                        print("Reset data cancel.")
                        return
                    })
                    msg.addButton("Yes", action: { [self] in
                        print("Reset data begin")
                        resetAllData()
                        print("Reset data end.")
                        return
                    })
                    msg.showWarning("Your all data will be deleted!", subTitle: "Your data in this device and on database online. Do you want to continue?")
                }
            }
            
    }
    func resetAllData()  {
        ProgressHUD.show()
        deleteLocalData()
        //delete data ỉn firebase
        var tempRef = ref.child("users").child(userInfor!.username).child("accounts")
        tempRef.removeValue()
        tempRef = ref.child("users").child(userInfor!.username).child("records")
        tempRef.removeValue()
        tempRef = ref.child("users").child(userInfor!.username).child("persons")
        tempRef.removeValue()
        tempRef = ref.child("users").child(userInfor!.username).child("locations")
        tempRef.removeValue()
        tempRef = ref.child("users").child(userInfor!.username).child("event")
        tempRef.removeValue()
        
        reloadView()
        ProgressHUD.dismiss()
        SCLAlertView().showSuccess("All data had been deleted!", subTitle: "")
    }
    func reloadView()
    {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = mainStoryBoard.instantiateViewController(identifier: "mainTabBar") as! UITabBarController
        tabBarController.selectedIndex = userInfor!.defaultScreen
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    override func viewDidLoad() {
        getUser()
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
