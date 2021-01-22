//
//  File.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/20/21.
//
import UIKit
import Foundation
import RealmSwift

class imgClass: Object{
    @objc dynamic var id = ""
    @objc dynamic var data: NSData?
    @objc dynamic var isUploaded = false
    @objc dynamic var isDeleted = false
    @objc dynamic var isChanged = true
    
    func del()
    {
        try! realm?.write{
        realm?.delete(self)
        }
    }
}
