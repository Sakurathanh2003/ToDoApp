//
//  SequenceExtensions.swift
//  MoneyManager
//
//  Created by MeiMei on 27/07/2023.
//

import Foundation

extension Sequence {
    func groupByMonth(byDate dateKey: (Iterator.Element) -> Date) -> [[Iterator.Element]] {
        var categories: [String :[Iterator.Element]] = [:]
        
        for element in self {
            let date = dateKey(element)
            let keyValue = "\(date.month)/\(date.year)"
            
            if !categories.keys.contains(where: { $0 == keyValue }) {
                categories[keyValue] = []
            }
            
            categories[keyValue]!.append(element)
        }
        
        return categories.map({ $0.value })
    }
    
    func groupByDay(byDate dateKey: (Iterator.Element) -> Date) -> [[Iterator.Element]] {
        var categories: [String :[Iterator.Element]] = [:]
        
        for element in self {
            let date = dateKey(element)
            let keyValue = "\(date.day)/\(date.month)/\(date.year)"
            
            if !categories.keys.contains(where: { $0 == keyValue }) {
                categories[keyValue] = []
            }
            
            categories[keyValue]!.append(element)
        }
        
        return categories.map({ $0.value })
    }
}
