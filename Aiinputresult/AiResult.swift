//
//  AiResult.swift
//  Aiinputresult
//
//  Created by J G on 2025/12/18.
//

import Foundation

// 必须遵守 Codable 才能进行 JSON 转换
struct AiResult: Codable, Identifiable {
    var id: String? // 修改这里：加一个问号
    var title: String
    var pmt: String
    var aiword: String
    var result: String
    var date: String
    
    // 因为遵守 Identifiable 协议，需要提供一个确定的 ID 给 SwiftUI 表格使用
    var realID: String {
        return id ?? UUID().uuidString // 如果 id 是空的，临时生成一个防止表格错乱
    }
}
