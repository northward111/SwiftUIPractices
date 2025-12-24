//
//  Int-RandomExclude.swift
//  LayoutAndGeometry
//
//  Created by hn on 2025/11/6.
//

import Foundation

extension Int {
    static func random(in range: ClosedRange<Int>, exclude: Int?) -> Int {
        if let exclude {
            var temp = Int.random(in: range)
            while temp == exclude {
                temp = Int.random(in: range)
            }
            return temp
        }else {
            return Int.random(in: range)
        }
    }
}
