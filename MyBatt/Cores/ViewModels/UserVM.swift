//
//  UserVM.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/16.
//

import Foundation
import Alamofire
import Combine
import SwiftUI
import CoreLocation
final class UserVM: ObservableObject{
    //MARK: properties
    private var userModel: UserModel = UserModel()
    @Published var isUserLoggined: Bool = false
    @Published var diagnoisResult:DiagnosisResponse?
    @Published var diagnosisImage: Image?
    private let diagnosisDataService: DiagnosisDataService
    var subscription = Set<AnyCancellable>()
    // 회원가입 완료 이벤트
    var registrationSuccess = PassthroughSubject<(), Never>()
    // 로그인 완료 이벤트
    var loginSuccess = PassthroughSubject<(), Never>()
    // 진단 완료
    var diagnosisSuccess = PassthroughSubject<DiagnosisResponse?,Never>()
    init(){
        self.diagnosisDataService = DiagnosisDataService()
        addSubscribers()
        checkToken()
    }
    deinit{
        subscription.forEach { can in
            can.cancel()
        }
    }
    /// 회원가입 하기
    func register(name: String, email: String, password: String){
        print("UserVM: register() called")
        // 직접 만든 인증 관련 클래스 - 회원가입
        AuthApiService.register(name: name, email: email, password: password)
            .sink { (completion: Subscribers.Completion<AFError>) in
                print("UserVM completion: \(completion)")
            } receiveValue: { (receivedUser: RegisterData?) in
//                self.loggedInUser = receivedUser
                self.registrationSuccess.send()
            }.store(in: &subscription)
    }
    
    /// 로그인 하기
    func login(email: String, password: String){
        print("UserVM: login() called")
        AuthApiService.login(email: email, password: password)
            .sink { (completion: Subscribers.Completion<AFError>) in
                print("UserVM completion: \(completion)")
            } receiveValue: {[weak self] (receivedUser: LogInResponse) in
                self?.userModel.userKey = receivedUser.key
                self?.userModel.token = UserDefaultsManager.shared.getTokens()
                self?.checkToken()
                self?.loginSuccess.send()
            }.store(in: &subscription)
    }
    func logout(){
        UserDefaultsManager.shared.clearAll()
        userModel = UserModel()
        self.checkToken()
    }
    
    func checkToken()
    {
        guard let userToken = userModel.token else { self.isUserLoggined = false; return}
        self.isUserLoggined = userToken.accessToken != "" && userToken.refreshToken != ""
    }
}

extension UserVM{
    private func addSubscribers(){ // 의존성 주입
        let diagnosisPublisher: Published<DiagnosisResponse?>.Publisher = diagnosisDataService.$diagnosisResponse
        diagnosisPublisher.sink{[weak self] output in
            print("diagnosisPublisher result called")
            print(output?.cropType ?? "0")
            self?.diagnosisSuccess.send(output)
        }
        .store(in: &subscription)
    }
    func requestImage( cropType:CropType,geo:CLLocationCoordinate2D,image: UIImage)->Void{
        self.diagnosisDataService.getDiagnosis(urlString: "http://15.164.23.13:8080/crop/diagnosis",
                                      geo: Geo(Double(geo.latitude),Double(geo.longitude)),
                                      cropType: cropType, image: image)
    }
}
