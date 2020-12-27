//
//  selectCategoryVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 11/28/20.
//
import UIKit

class selectCategoryVC: UIViewController,selectLendOrBorrowDelegate {
    func didSelectLendOrBorrow(_type: Int, temp: polyRecord) {
        self.delegate?.didSelectRepayOrCollectDebt(_type: _type, temp: temp)
        self.navigationController?.popViewController(animated: false)
    }
    
    var selectedSection = -1
    var selectedRow = -1
    weak var delegate: selectCategoryDelegate? = nil
    
    var type = 0
    var isOpened : [Bool] = []
    var dataSource :[[String]] = []
    @IBOutlet weak var listTv: UITableView!
    
    func getData(section: Int, row: Int, _type: Int, _delegate: selectCategoryDelegate) {
        type = _type
        delegate = _delegate
        selectedSection = section
        selectedRow = row
    }
    func loadData()  {
        switch type {
        case 0:
            dataSource = categoryValues().expense
            for _ in dataSource
            {
                isOpened.append(false)
            }
        case 1:
            dataSource = categoryValues().income
        case -1:
            return
        default:
            dataSource = categoryValues().other
        }
        if type == 0 && selectedSection != -1
        {
            isOpened[selectedSection] = true
        }
        listTv.reloadData()
        if selectedRow != -1
        {

            listTv.selectRow(at: IndexPath(row: selectedRow, section: selectedSection), animated: true, scrollPosition: .none)
        }
    }
    override func viewDidLoad() {
        
        listTv.register(categoryCell.self, forCellReuseIdentifier: "categoryCell")
        listTv.register(categoryCell.self, forCellReuseIdentifier: "detailCategoryCell")
        loadData()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickDone(_ sender: Any) {
        if selectedSection != -1
        {
            didSelectedCategory(section: selectedSection, row: selectedRow)
        }
        self.navigationController?.popViewController(animated: true)
    }
    func didSelectedCategory(section: Int, row: Int)
    {
        switch type {
        case 0:
            if section == 11 && row == 2
            {
                let dest = self.storyboard?.instantiateViewController(identifier: "chooseLendOrBorrowVC") as! chooseLendOrBorrowVC
                dest.delegate = self
                dest.type = 0
                self.navigationController?.pushViewController(dest, animated: false)
            }
            else
            {
                delegate?.didSelectCategory(section: section, row: row)
                self.navigationController?.popViewController(animated: false)
                return
            }
        case 1:
            if row == 4
            {
                let dest = self.storyboard?.instantiateViewController(identifier: "chooseLendOrBorrowVC") as! chooseLendOrBorrowVC
                dest.delegate = self
                dest.type = 1
                self.navigationController?.pushViewController(dest, animated: false)
            }
            else
            {
                delegate?.didSelectCategory(section: section, row: row)
                self.navigationController?.popViewController(animated: false)
                return
            }
        case 2,3:
            if row == 2 || row == 3
            {
                let dest = self.storyboard?.instantiateViewController(identifier: "chooseLendOrBorrowVC") as! chooseLendOrBorrowVC
                dest.delegate = self
                dest.type = row - 2
                self.navigationController?.pushViewController(dest, animated: false)
            }
            else
            {
                delegate?.didSelectCategory(section: section, row: row)
                self.navigationController?.popViewController(animated: false)
                return
            }
        default:
            delegate?.didSelectCategory(section: section, row: row)
            self.navigationController?.popViewController(animated: false)
            return
        }
    }
}
extension selectCategoryVC : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if type == 0
    {
        if isOpened[section]
        {
        return dataSource[section].count
        }
        else
        {
            return 1
        }
    }
    else
    {
        return dataSource[section].count
    }
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if(type == 0)
    {
        if(indexPath.row == 0)
        {
        let cell: categoryCell = listTv.dequeueReusableCell(withIdentifier: "categoryRow", for: indexPath) as! categoryCell
        cell.getData(name: dataSource[indexPath.section][indexPath.row], id: 0)
        return cell
        }
        else
        {
            let cell: detailCategoryCell = listTv.dequeueReusableCell(withIdentifier: "detailCategoryRow", for: indexPath) as! detailCategoryCell
            cell.getData(name: dataSource[indexPath.section][indexPath.row], id: 0)
            return cell
        }
    }
    else
    {
        let cell: detailCategoryCell = listTv.dequeueReusableCell(withIdentifier: "detailCategoryRow", for: indexPath) as! detailCategoryCell
        cell.getData(name: dataSource[indexPath.section][indexPath.row], id: 0)
        return cell
    }
    
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && type == 0
        {
            isOpened[indexPath.section] = !isOpened[indexPath.section]
            listTv.reloadSections(    IndexSet.init(integer: indexPath.section), with: .fade)
            if isOpened[indexPath.section] == true
                {
                listTv.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedSection = indexPath.section
                selectedRow = indexPath.row
                return
                }
            selectedRow = -1
            selectedSection = -1
            return
        }
        didSelectedCategory(section: indexPath.section, row: indexPath.row)
        }
}

