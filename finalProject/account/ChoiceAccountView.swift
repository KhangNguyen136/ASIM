//
//  ChoiceAccountView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/2/20.
//

import UIKit

class ChoiceAccountView: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    var currencyMode:Bool = false
    var accountMode:Bool = false
    var bankingMode:Bool = false
    var timeMode: Bool = false
    var termmMode: Bool = false
    let currencyLabel = ["Vietnamese Dong", "United States Dollar"]
    let accountLabel = ["Cash", "Banking Account"]
    let abbrName = ["ACB", "TPBank","DAB","SeABank","ABBANK","BacABank","VietCapitalBank","MSB","TCB","KienLongBank","Nam A Bank","NCB","VPBank","HDBank","OCB","MB","PVcombank","VIB","SCB","SGB","SHB","STB","VAB","BVB","VietBank","PG Bank","EIB","LPB","VCB","CTG","BIDV","NHCSXH/VBSP","VDB","CB","Oceanbank","GPBank","Agribank"]
    let bankName = ["Ngân hàng Á Châu","Ngân hàng Tiên Phong","Ngân hàng Đông Á","Ngân hàng Đông Nam Á","Ngân hàng An Bình","Ngân hàng Bắc Á","Ngân hàng Bản Việt","Hàng Hải Việt Nam","Kỹ Thương Việt Nam","Kiên Long","Nam Á","Quốc Dân","Việt Nam Thịnh Vượng","Phát triển nhà Thành phố Hồ Chí Minh","Phương Đông","Quân đội","Đại chúng","Quốc tế","Sài Gòn","Sài Gòn Công Thương","Sài Gòn-Hà Nội","Sài Gòn Thương Tín","Việt Á","Bảo Việt","Việt Nam Thương Tín","Xăng dầu Petrolimex","Xuất Nhập khẩu Việt Nam","Bưu điện Liên Việt","Ngoại thương Việt Nam","Công Thương Việt Nam","Đầu tư và Phát triển Việt Nam","Ngân hàng Chính sách xã hội","Ngân hàng Phát triển Việt Nam","Ngân hàng Xây dựng","Ngân hàng Đại Dương","Ngân hàng Dầu Khí Toàn Cầu","Ngân hàng Nông nghiệp và Phát triển Nông thôn VN"]
    let bankImg = ["bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank","bank"]
    let howLong = ["1 month", "3 months", "6 months","1 year","2 years","5 years", "10 years", "other"]
    let term = ["1 week","2 weeks", "3 weeks","1 month", "3 months", "6 months","12 months"]
    var backgroundImage: UIImageView!

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil )
    }
    override func viewDidLoad() {
        
           super.viewDidLoad()
           self.backgroundImage = UIImageView(image: UIImage(named: "background-1"))
           self.backgroundImage.contentMode = .scaleAspectFill
        self.view.insertSubview(self.backgroundImage, at: 0)
        if bankingMode == true {
            lblTitle.text = "Choose Bank"
        }
        else if currencyMode == true {
            lblTitle.text = "Choose Currency"
        }
        else if accountMode == true {
            lblTitle.text = "Choose Account"
        }
        else if timeMode == true {
            lblTitle.text = "For how long"
        }
    }
        

}
extension ChoiceAccountView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currencyMode == true {
            return currencyLabel.count
        }
        else if accountMode == true{
            return accountLabel.count
        }
        else if bankingMode == true {
            return bankName.count
        }
        else if timeMode == true{
            return howLong.count
        }
        else if termmMode == true{
            return term.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if currencyMode == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = currencyLabel[indexPath.row]
            cell.imgIcon.image = UIImage(named: currencyLabel[indexPath.row])
            return cell
               }
               else if accountMode == true{
           let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = accountLabel[indexPath.row]
            cell.imgIcon.image = UIImage(named: accountLabel[indexPath.row])
                      return cell
               }
         else if bankingMode == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankingCell", for: indexPath) as! BankingCell
            cell.lblTitle.text = abbrName[indexPath.row]
            cell.lblInfo.text = bankName[indexPath.row]
            cell.imgIcon.image = UIImage(named: "Banking Account")
                      return cell
        }
        else if timeMode == true {
           let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = howLong[indexPath.row]
            cell.imgIcon.image = UIImage(named: "date")
            return cell
        }
         else if termmMode == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceAccountViewCell", for: indexPath) as! ChoiceAccountViewCell
            cell.txtText.text = term[indexPath.row]
            cell.imgIcon.image = UIImage(named: "date")
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currencyMode == true {
            if indexPath.row == 1{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currNotification"), object: nil, userInfo: ["currency": "USD"])
            }
            else {
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currNotification"), object: nil, userInfo: ["currency": "VND"])
            }
            dismiss(animated: true, completion: nil)
        }
        else if bankingMode == true{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bankNotification"), object: nil, userInfo: ["nameBank": "Ngân hàng \(abbrName[indexPath.row])","imgBank":"\(bankImg[indexPath.row])"])
            dismiss(animated: true, completion: nil)
        }
        else if accountMode == true{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "accountNotification"), object: nil, userInfo: ["accountType": accountLabel[indexPath.row]])
            dismiss(animated: true, completion: nil)
        }
        else if timeMode == true{
            if indexPath.row != 7{ NotificationCenter.default.post(name: NSNotification.Name(rawValue: "timeNotification"), object: nil, userInfo: ["time": howLong[indexPath.row]])}
            dismiss(animated: true, completion: nil)
        }
        else if termmMode == true{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "termNotification"), object: nil, userInfo: ["term": term[indexPath.row]])
            dismiss(animated: true, completion: nil)
        }
            
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if bankingMode == true {
                    return 80
        }
        return 50
    }
    
}
extension Notification.Name {
static let currNotification = Notification.Name("currNotification")
static let bankNotification = Notification.Name("bankNotification")
static let accountNotification = Notification.Name("accountNotification")
static let timeNotification = Notification.Name("timeNotification")
static let termNotification = Notification.Name("termNotification")
}
