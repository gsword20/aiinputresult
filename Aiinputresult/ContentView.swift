//
//  ContentView.swift
//  Aiinputresult
//
//  Created by J G on 2025/12/18.
//

import SwiftUI

struct ContentView: View {
    // 表单输入变量
    @State private var title: String = ""
    @State private var pmt: String = ""
    @State private var aiword: String = ""
    @State private var result: String = ""
    
    // 存储从后端获取的数据
    @State private var results: [AiResult] = []
    
    let apiURL = "http://207.246.88.112:8080/ai-results"

    var body: some View {
        NavigationView {
            VStack {
                // --- 输入表单区域 ---
                Form {
                    Section(header: Text("新建记录")) {
                        TextField("标题 (Title)", text: $title)
                        TextField("提示词 (PMT)", text: $pmt)
                        TextField("关键词 (AI Word)", text: $aiword)
                        TextEditor(text: $result)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    }
                    
                    Button(action: saveData) {
                        HStack {
                            Spacer()
                            Text("保存到后台数据库")
                                .bold()
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.blue)
                }
                .frame(height: 350)

                // --- 数据列表区域 ---
                //List(results) { item in
                List(results, id: \.realID) { item in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(item.title).font(.headline)
                            Spacer()
                            Text(item.date).font(.caption).foregroundColor(.gray)
                        }
                        Text("ID: \(item.id)").font(.system(size: 10, design: .monospaced))
                        Text(item.result).font(.subheadline).lineLimit(2)
                    }
                }
                .navigationTitle("AI 结果管理器")
                .onAppear(perform: fetchData) // 页面出现时加载数据
                .refreshable { fetchData() }  // 下拉刷新
            }
        }
    }

    // MARK: - 网络请求：保存数据 (POST)
    func saveData() {
        // 1. 准备随机 ID 和当前日期
        let randomID = String(Int.random(in: 100000...999999))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let currentDate = formatter.string(from: Date())
        
        let newEntry = AiResult(id: randomID, title: title, pmt: pmt, aiword: aiword, result: result, date: currentDate)
        
        guard let encoded = try? JSONEncoder().encode(newEntry) else { return }
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("保存失败: \(error.localizedDescription)")
                return
            }
            // 保存成功后刷新列表并清空输入框
            DispatchQueue.main.async {
                fetchData()
                title = ""; pmt = ""; aiword = ""; result = ""
            }
        }.resume()
    }

    // MARK: - 网络请求：获取数据 (GET)
    func fetchData() {
        URLSession.shared.dataTask(with: URL(string: apiURL)!) { data, response, error in
            if let error = error {
                print("❌ 网络错误: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                // --- 关键调试代码：打印原始字符串 ---
                if let rawString = String(data: data, encoding: .utf8) {
                    print("DEBUG: 收到原始 JSON: \(rawString)")
                }
                // -------------------------------

                do {
                    let decodedResponse = try JSONDecoder().decode([AiResult].self, from: data)
                    DispatchQueue.main.async {
                        self.results = decodedResponse.reversed()
                    }
                } catch {
                    print("❌ 解析失败: \(error)") // 这行会告诉你具体哪个字段对不上
                }
            }
        }.resume()
    }
}
