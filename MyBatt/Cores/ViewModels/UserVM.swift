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
    static let baseURL = "https://mybatboo.kr/"
    private var userModel: UserModel = UserModel()
    @Published var isUserLoggined: Bool = false
    @Published var diagnoisResult:DiagnosisResponse?
    @Published var diagnosisImage: Image?
    @Published var outbreakModel: OutbreakModel?
    
    private let diagnosisDataService: DiagnosisDataService
    var subscription = Set<AnyCancellable>()
    var outbreakSubscription: AnyCancellable?
    // 회원가입 완료 이벤트
    var registrationSuccess = PassthroughSubject<(), Never>()
    // 로그인 완료 이벤트
    var loginSuccess = PassthroughSubject<(), Never>()
    // 진단 완료
    var diagnosisSuccess = PassthroughSubject<(DiagnosisResponse?),Never>()
    var diagnosisFail = PassthroughSubject<(String?),Never>()
    init(){
        self.diagnosisDataService = DiagnosisDataService()
        addSubscribers()
        checkToken()
    }
    deinit{
        subscription.forEach { can in
            can.cancel()
        }
        self.outbreakSubscription?.cancel()
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
//                guard let receivedUser = receivedUser else { return }
//                receivedUser.
//                UserDefaultsManager.shared.setTokens(accessToken: receivedUser.accessToken, refreshToken: receivedUser.refreshToken)
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
        AuthApiService.tokenCheck().sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let err):
                    self.isUserLoggined = false
                    print(err)
                }
            } receiveValue: { val in
                self.isUserLoggined = val.data != nil
        }.store(in: &subscription)
    }
}
extension UserVM{
    func fetchOutbreakList(){
        if outbreakModel != nil { return }
        
                print("AuthApiService - fetchCurrentUserInfo() called")
                let storedTokenData = UserDefaultsManager.shared.getTokens()
        
                let credential = OAuthCredential(accessToken: storedTokenData.accessToken,
                                                 refreshToken: storedTokenData.refreshToken,
                                                 expiration: Date(timeIntervalSinceNow: 60 * 60))
                // Create the interceptor
                let authenticator = OAuthAuthenticator()
                let authInterceptor = AuthenticationInterceptor(authenticator: authenticator,
                                                                credential: credential)
    
        self.outbreakSubscription = ApiClient.shared.session
            .request(CropInfoRouter.NoticeList, interceptor: authInterceptor)
                    .publishDecodable(type: ResponseWrapper<OutbreakModel>.self)
                    .value()
                    .sink(receiveCompletion: {[weak self] completion in
                        switch completion{
                        case .finished:
                            print("가져오기 성공")
                        case .failure(let error):
                            print("가져오기 실패")
                            print(error.localizedDescription)
                        }
                        self?.outbreakSubscription?.cancel()
                    }, receiveValue: { output in
                        self.outbreakModel = output.data
                    })
    }
}

extension UserVM{
    private func addSubscribers(){ // 의존성 주입
        let diagnosisPublisher: Published<DiagnosisResponse?>.Publisher = diagnosisDataService.$diagnosisResponse
        diagnosisPublisher.sink{[weak self] output in
            print("diagnosisPublisher result called")
            self?.diagnosisSuccess.send(output)
        }
        .store(in: &subscription)
        
        let diagnosisErrorPublisher: Published<String?>.Publisher = diagnosisDataService.$diagnosisCode
        diagnosisErrorPublisher.sink{[weak self] output in
            print("diagnosisError result called: \(output)")
            self?.diagnosisFail.send(output)
        }
        .store(in: &subscription)
    }
    
    func requestImage( cropType:DiagCropType,geo:CLLocationCoordinate2D,image: UIImage)->Void{
        self.diagnosisDataService.getDiagnosis(urlString: UserVM.baseURL+"crop/diagnosis",
                                      geo: Geo(Double(geo.latitude),Double(geo.longitude)),
                                      cropType: cropType, image: image)
    }
}
