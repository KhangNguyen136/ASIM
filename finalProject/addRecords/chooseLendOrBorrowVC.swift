//
//  chooseLendOrBorrowVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 12/10/20.
//

import UIKit
import RealmSwift
import SCLAlertView
class chooseLendOrBorrowVC: UIViewController {
    var delegate: selectLendOrBorrowDelegate? = nil
    var type = 0
    var dataSource: [polyRecord] = []
    let realm = try! Realm()
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var filterBtn: UIButton!
    override func viewDidLoad() {
        filterBtn.semanticContentAttribute = .forceRightToLeft
        loadData()
        listTV.register(lendOrBorrowCell.self, forCellReuseIdentifier: "lendOrBorrowCell")
        listTV.reloadData()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func loadData() {
        dataSource = []
        let temp = realm.objects(User.self)[0].records
        if !temp.isEmpty
        {
            if type == 1
            {
            for i in temp
                {
                if i.type == 2 && i.lend?.isCollected == false && i.isDeleted == false
                    {
                    dataSource.append(i)
                    }
                }
                self.navigationItem.title = "Select a lend"
            }
            else
            {
            for i in temp
            {
                if i.type == 3 && i.borrow?.isRepayed == false && i.isDeleted == false
                {
                    dataSource.append(i)
                }
            }
                self.navigationItem.title = "Select a borrow"
            }
        }
        if dataSource.isEmpty == true
        {
            if type == 1{
                SCLAlertView().showWarning("No lend recorded!", subTitle: "")
            }
            else
            {
                SCLAlertView().showWarning("No borrow recorded!", subTitle: "")
            }
        }
        }
    @IBAction func filterHistory(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "filterHistoryVC") as! filterHistoryVC
//        dest.delegate = self
        self.navigationController?.pushViewController(dest, animated: false)
    }
    }
    extension chooseLendOrBorrowVC: UITableViewDelegate, UITableViewDataSource
    {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell: lendOrBorrowCell = listTV.dequeueReusableCell(withIdentifier: "lendOrBorrowRow", for: indexPath) as! lendOrBorrowCell
            
            cell.getData(_record: dataSource[indexPath.row])
            
            return cell
    }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.navigationController?.popViewController(animated: false)
            delegate?.didSelectLendOrBorrow(_type: type, temp: dataSource[indexPath.row])
        }
    }
    
extension UINavigationController {

  public func pushViewController(viewController: UIViewController,
                                 animated: Bool,
                                 completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
func popViewController(
        animated: Bool,
        completion: @escaping () -> Void)
    {
        popViewController(animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
