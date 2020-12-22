//
//  filterHistoryVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/25/20.
//

import UIKit

class filterHistoryVC: UIViewController {

    var delegate: chooseFilterTypeDelegate? = nil
    var isOpened: [Bool] = [false,false,false,false,false,false]
    let dataSource: [[String]] = [["Date","Today","Select day"],
                                  ["Week","Yesterday","Select day"],
                                  ["Month","This month","Select month"],
                                  ["Quarter","Quarter I","Quarter II","Quarter III","Quarter IV"],
                                  ["Custom","Start date: ","End date: "],
                                  ["All"]]
    @IBOutlet weak var listTv: UITableView!
    override func viewDidLoad() {
        listTv.register(filterHistoryCell.self, forCellReuseIdentifier: "filterHistoryCell")
        listTv.register(sectionFilterHistoryCell.self, forCellReuseIdentifier: "sectionFilterHistoryCell")
        listTv.register(seclectDateFilterHistoryCell.self, forCellReuseIdentifier: "seclectDateFilterHistoryCell")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
extension filterHistoryVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOpened[section]
        {
        return dataSource[section].count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: sectionFilterHistoryCell = listTv.dequeueReusableCell(withIdentifier: "sectionFilterHistoryRow", for: indexPath) as! sectionFilterHistoryCell
            cell.content.text = dataSource[indexPath.section][indexPath.row]
            return cell
        }
        else
        {
            if indexPath.section == 4
            {
                let cell: seclectDateFilterHistoryCell = listTv.dequeueReusableCell(withIdentifier: "seclectDateFilterHistoryRow", for: indexPath) as! seclectDateFilterHistoryCell
                cell.content.text = dataSource[indexPath.section][indexPath.row]
                return cell
            }
            else
            {
                let cell: filterHistoryCell = listTv.dequeueReusableCell(withIdentifier: "filterHistoryRow", for: indexPath) as! filterHistoryCell
                cell.content.text = dataSource[indexPath.section][indexPath.row]
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            isOpened[indexPath.section] = !isOpened[indexPath.section]
            listTv.reloadSections(	IndexSet.init(integer: indexPath.section), with: .fade)
            if isOpened[indexPath.section] == true
                {
                listTv.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
        }
        else if indexPath.section == 4
        {
            return
        }
        else
        {
            delegate?.didSelectedFilterHistory(row: indexPath.row, section: indexPath.section)
            self.navigationController?.popViewController(animated: false)
        }
    }
    
}
