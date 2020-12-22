//
//  CustomView.swift
//  finalProject
//
//  Created by Nguyễn Bình Nguyên on 12/14/20.
//

import UIKit

class CustomView: UIView {
   
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var txtText: UITextField!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupView()
    }
   private func setupView(){
    Bundle.main.loadNibNamed("CustomView", owner: self, options: nil)
        addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  
    }
}
