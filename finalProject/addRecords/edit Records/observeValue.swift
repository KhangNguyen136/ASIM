//
//  observeValue.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import Foundation
import RealmSwift

protocol selectCategoryDelegate: class {
    func didSelectCategory(section: Int, row: Int)
    func didSelectRepayOrCollectDebt(_type: Int, temp: polyRecord)
}
protocol selectAccountDelegate: class {
    func didSelectAccount(temp: polyAccount, name: String)
}

protocol selectLendOrBorrowDelegate: class {
    func didSelectLendOrBorrow(_type: Int, temp: polyRecord)
}

protocol settingDelegate: class {
    func changedHideAmountValue(value: Bool)
    func changedCurrency(value: Int)
}

class settingObserve: NSObject {
    @objc dynamic var userInfor: User? = nil
    var delegate: settingDelegate? = nil
    func updateHideAmount() {
        delegate?.changedHideAmountValue(value: userInfor!.isHideAmount)
    }
    func updateCurrency()
    {
        delegate?.changedCurrency(value: userInfor!.currency)
    }
    init(user: User) {
        userInfor = user
        super.init()
    }
}

class settingObserver: NSObject {
    @objc var objectToObserve: settingObserve
    var observation: NSKeyValueObservation?
    var observation2: NSKeyValueObservation?

    init(object: settingObserve) {
        objectToObserve = object
        super.init()
        
        observation = observe(
            \.objectToObserve.userInfor?.isHideAmount,
            options: [.old, .new]
        ) { [self] object, change in
            print("isHideAmount changed from: \(String(describing: change.oldValue!)), updated to: \(String(describing: change.newValue!))")
            objectToObserve.updateHideAmount()
        }
        observation2 = observe(
            \.objectToObserve.userInfor?.currency,
            options: [.old, .new]
        ) { [self] object, change in
            print("Currency changed from: \(String(describing: change.oldValue!)), updated to: \(String(describing: change.newValue!))")
            objectToObserve.updateCurrency()
        }
    }
}
