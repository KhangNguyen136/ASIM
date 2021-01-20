//
//  FeebackView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 1/19/21.
//

import UIKit
import MessageUI
import RealmSwift

class FeebackView: UIViewController, UITextFieldDelegate, UITextViewDelegate  {

    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var subject: UITextView!
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var body: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        let realm = try! Realm()
           
        let userEmail = (realm.objects(User.self)[0]).email
           subject.delegate = self
           body.delegate = self
        txtTo.text = "nguyennguyen1112000@gmail.com"
        txtFrom.text = userEmail
        subject.text = "Sổ thu chi ASIM feeback, sent from \(userEmail)"
        body.text = "Nội dung mail"
    }
    
    

    @IBAction func sendEmail(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else {
            Notice().showAlert(content: "Check if your device support email")
                  return
              }
              let composer = MFMailComposeViewController()
              composer.mailComposeDelegate = self
        composer.setToRecipients(["nguyennguyen1112000@gmail.com"]);  composer.setSubject(subject.text)
        composer.setMessageBody(body.text, isHTML: false)
              present(composer, animated: true)
          }
    
}

extension FeebackView: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        switch result {
        case .cancelled:
        print("Mail cancelled")
        case .saved:
        print("Mail saved")
        case .sent:
        print("Mail sent")
        case .failed:
        break

        }
        controller.dismiss(animated: true, completion: nil)
    }
}
