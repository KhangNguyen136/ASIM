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
    @objc dynamic var id = -1
    @objc dynamic var data: NSData?
    @objc dynamic var isUploaded = false
    @objc dynamic var isDeleted = false
}
