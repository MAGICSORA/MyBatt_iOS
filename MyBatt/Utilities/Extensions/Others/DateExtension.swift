//
//  DateExtension.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/26.
//

import Foundation
extension Date{
    static func changeDateFormat(dateString:String)->String{

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yy년 MM월 dd일"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate // 출력: 2023-05-26
        } else {
            return "잘못된 날짜"
        }
    }
    static var weekAgo: Date{
        let date = Date()
        let week: TimeInterval = 60 * 60 * 24 * 7
        return date.addingTimeInterval(-week)
    }
    var getKoreanString:String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일"
        return formatter.string(from: self)
    }
}
