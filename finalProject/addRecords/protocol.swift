//
//  protocol.swift
//  finalProject
//
//  Created by Khang Nguyen on 1/19/21.
//

import Foundation

protocol selectDestinationAccountDelegate: class {
    func didSelectDestAccount(temp: polyAccount,name: String)
}

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

protocol delteImageDelegate: class {
    func didDeletedImage()
}
protocol settingDelegate: class {
    func changedHideAmountValue(value: Bool)
    func changedCurrency(value: Int)
}
