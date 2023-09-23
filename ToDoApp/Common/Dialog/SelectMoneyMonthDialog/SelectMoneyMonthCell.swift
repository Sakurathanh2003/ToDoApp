//
//  SelectMoneyMonthCell.swift
//  MoneyManager
//
//  Created by MeiMei on 30/07/2023.
//

import UIKit

class SelectMoneyMonthCell: UICollectionViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    
    func bindData(viewModel: ListMoneyWithMonthViewModel) {
        monthLabel.text = viewModel.date.description(format: "MM-YYYY")
    }
    
    func updateSelectedState(isSelected: Bool) {
        self.backgroundColor = isSelected ? UIColor(rgb: 0x96E9FC, alpha: 0.7) : .clear
    }
}
