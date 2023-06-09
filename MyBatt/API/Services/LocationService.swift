//
//  LocationService.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/12.
//

import Foundation
import CoreLocation
import Combine
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate{
    static let shared = LocationService()
    private let locationManager = CLLocationManager()
    @Published var isLoading = false{
        didSet{
            if isLoading == false{
                locationManager.stopUpdatingLocation()
            }
        }
    }
//    @Published var address: String? = nil
    lazy var locationPassthrough = PassthroughSubject<Geo,Never>()
    lazy var addressPasthrough = PassthroughSubject<String?,Never>()
    private override init() {
        super.init()
        print("LocationService Init!!")
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        switch locationManager.authorizationStatus{
        case .denied: break
        case .notDetermined, .restricted:
            locationManager.requestWhenInUseAuthorization()
        default: break
        }
    }
    deinit{
        print("사라진 거임!")
    }
    func getCurrentLocation(){
        isLoading = true
        print("request start!!")
        locationManager.requestLocation()
//      메모리 즉시 해제가 가능하게 함
        DispatchQueue.main.asyncAfter(deadline: .now()+3){ [weak self] in
            self?.isLoading = false
        }
    }
    func startUpdatingLocation(){
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 사용자가 장치에서 위치 서비스를 활성화하지 않았을때나,
        // 건물 내부에 있어 GPS 신호가 잡히지 않을 경우.
        // 예를 들자면 사용자에게 GPS 신호가 있는 장소로 걸어가라고 요청하는 경고를 표시하는 것이 좋습니다.
        print("didFailWithError")
        print(error.localizedDescription)
        isLoading = false
    }
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations라는 배열로 현재 위치를 가져온다.
        // 첫번째 인덱스에 있는 정보로 활용이 가능하다.
        defer{
            isLoading = false
        }
        if let location = locations.last {
            self.locationPassthrough.send((location.coordinate.latitude,location.coordinate.longitude))
        }
        isLoading = false
    }
//  위치 좌표를 통한 한국어 주소 반환
    func requestAddress(geo:Geo){
        guard (33.0 <= geo.latitude && geo.latitude <= 43) || (124.0 <= geo.longtitude && geo.longtitude <= 132) else {
            self.addressPasthrough.send("위치를 찾을 수 없습니다")
            return
        }
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: geo.0,longitude: geo.1)) {[weak self] marks, error in
            guard let self = self else {return}
            if let pm: CLPlacemark = marks?.first{
                let address: String = "\(pm.locality ?? "") \(pm.name ?? "")"
                self.addressPasthrough.send(address)
            }else{
                self.addressPasthrough.send(nil)
            }
        }
    }
    func requestAddressAsync(geo:Geo) async -> String{
        guard (33.0 <= geo.latitude && geo.latitude <= 43) || (124.0 <= geo.longtitude && geo.longtitude <= 132) else {
            return "위치를 찾을 수 없습니다"
        }
        let s:[CLPlacemark]? = try? await CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: geo.0,longitude: geo.1))
        if let pm = s?.first{
            return "\(pm.locality ?? "") \(pm.name ?? "")"
        }
        return "찾을 수 없는 값!!"
    }
}
