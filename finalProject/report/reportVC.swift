//
//  reportVC.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import UIKit

class reportVC: UITableViewController {

    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!

    @IBAction func toChart1_0(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "chartType1VC") as! chartType1VC
        dest.type = 0
        self.navigationController?.pushViewController(dest, animated: true)
    }
    @IBAction func toChart1_1(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "chartType1VC") as! chartType1VC
        dest.type = 1
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    @IBAction func toChart2_1(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "chartType2VC") as! chartType2VC
        dest.type = 1
        self.navigationController?.pushViewController(dest, animated: true)
    }
    @IBAction func toChart2_0(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "chartType2VC") as! chartType2VC
        dest.type = 0
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
    @IBAction func toChart3_0(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "chartType3VC") as! chartType3VC
        dest.type = 0
        self.navigationController?.pushViewController(dest, animated: true)
    }
    @IBAction func toChart3_1(_ sender: Any) {
        let dest = self.storyboard?.instantiateViewController(identifier: "chartType3VC") as! chartType3VC
        dest.type = 1
        self.navigationController?.pushViewController(dest, animated: true)
    }
    func setLayout(view: UIView)
    {
//        view.layer.borderWidth = 1.0
//        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = view.frame.width/8
    }
    override func viewDidLoad() {
        setLayout(view: btn1)
        setLayout(view: btn2)
        setLayout(view: btn3)
        setLayout(view: btn4)
        setLayout(view: btn5)
        setLayout(view: btn6)


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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
