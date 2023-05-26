//
//  DiagnosisDataService.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/10.
//

import Foundation
import SwiftUI
import Combine

final class DiagnosisDataService{
    @Published var diagnosisResponse: DiagnosisResponse?
    var diagnosisSubscription: AnyCancellable?
    let boundary = UUID().uuidString
    init(){}
    deinit{
        diagnosisSubscription?.cancel()
    }
    //MARK: -- 리프레시 토큰으로 AccessToken을 refresh후 실제 진단 모델 로직 실행
    func getDiagnosis(urlString: String,geo:Geo,cropType: CropType,image:UIImage){
        let refreshToken = UserDefaultsManager.shared.getTokens().refreshToken
        var authRequest = try! URLRequest(url: URL(string:"http://15.164.23.13:8080/member/refresh")!, method: .post)
        authRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authRequest.httpBody = try? JSONSerialization.data(withJSONObject: ["refreshToken": refreshToken])
        URLSession.shared.dataTask(with: authRequest){(data,response,error) in
            if let error = error{
                print("Error: \(error.localizedDescription)")
            }else if let data = data{
                let token = try! JSONDecoder().decode(RefreshResponse.self, from: data)
                print(token.accessToken)
                UserDefaultsManager.shared.setTokens(accessToken: token.accessToken, refreshToken: refreshToken)
                self._getDiagnosis(urlString: urlString, geo: geo, cropType: cropType, image: image)
            }
        }.resume()
    }
    // MARK: -- 실제 진단 로직
    private func _getDiagnosis(urlString: String,geo:Geo,cropType: CropType,image: UIImage){
        guard let url = URL(string: urlString) else {
            print("There is no ulr string")
            return
        }
        let diagnosis = """
            { "userLatitue":\"\(geo.latitude)\",
                "userLongitude":\"\(geo.longtitude)\",
                "regDate":\"\(Date().formatted(.iso8601))\",
            "cropType":\"\(cropType.rawValue)\"
            }
            """
        //        2023-02-20T11:22:33.000000
        let urlRequest: URLRequest = getURLRequest(url: url, info: diagnosis, image: image)
        self.diagnosisSubscription = NetworkingManager.upload(request: urlRequest)
            .tryMap({ (data) -> DiagnosisResponse in
                guard let diagnosis: ResponseWrapper<DiagnosisResponse> = try? JSONDecoder().decode(ResponseWrapper<DiagnosisResponse>.self, from: data) else{
                    throw fatalError("Diagnosis Wrong")
                }
                return diagnosis.data
            })
            .sink(receiveCompletion: NetworkingManager.handleCompletion(completion:)) { [weak self] (diagnosis: DiagnosisResponse) in
                print("DiagnosisResponse sinked")
                self?.diagnosisResponse = diagnosis
            }
    }
    
}
extension DiagnosisDataService{
    
    //MARK: -- 요청 형식을 만드는 코드
    private func getURLRequest(url: URL,info: String,image:UIImage)->URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary= \(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(UserDefaultsManager.shared.getTokens().accessToken)", forHTTPHeaderField: "Authorization")
        let dataImage = image.jpegData(compressionQuality: 1)!
        let requestBody = getRequestBody(imageInfo: info, image: dataImage)
        request.httpBody = requestBody
        return request
    }
    
    private func getRequestBody(imageInfo: String,image: Data)->Data{
        var requestBody = Data()
        // Add any additional form fields
        requestBody.append("--\(self.boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"requestInput\"\r\n\r\n".data(using: .utf8)!)
        requestBody.append("\(imageInfo)\r\n".data(using: .utf8)!)
        requestBody.append("--\(self.boundary)\r\n".data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"image\"; filename=\"image_jpeg\"\r\n".data(using: .utf8)!)
        requestBody.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        requestBody.append(image)
        requestBody.append("\r\n".data(using: .utf8)!)
        // Add the closing boundary
        requestBody.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return requestBody
    }
    
    func testJSONString(data: Data){
        do {
            // JSON 객체로 변환
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // JSON 객체를 Data로 직렬화
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            
            // Data를 String으로 변환
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            } else {
                print("Failed to convert Data to String.")
                
            }
        } catch {
            print("JSON serialization failed: \(error.localizedDescription)")
        }
    }
}
