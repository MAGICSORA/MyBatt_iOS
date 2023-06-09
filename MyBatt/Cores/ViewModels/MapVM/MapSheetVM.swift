//
//  MapSheetVM.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/16.
//
import Foundation
import SwiftUI
import Alamofire
import Combine


final class MapSheetVM:ObservableObject{
    @Published var isGPSOn : Bool = false
    // 검색 결과 좌표 반환을 위한 Passthrough
    var centerPassthrough = PassthroughSubject<Geo,Never>()
    // 여기 나중에 true로 수정해야함!
    @Published var nearDiseaseItems: [DiagCropType:[MapDiseaseResponse]]?
    var subscription = Set<AnyCancellable>()
    lazy var mapQueryDataService: MapQueryDataService = MapQueryDataService()
    init(){}
    deinit{
        subscription.forEach { can in can.cancel() }
        print("MapSheetVM 메모리 해제")
    }
}
//MARK: -- 검색어 좌표 변환
extension MapSheetVM{
    func requestLocation(query:String){
        guard query != "" else { return }
        mapQueryDataService.getMapCoordinate(query: query)
    }
}

extension MapSheetVM{
    private func addSubscribers(){ // 의존성 주입
        /// 주변 위치가 바뀌는 것은 바인딩하지 않는다. 필터의 정보가 바뀌는 것만 한다.
//        let myLocationPublisher: Published<Geo>.Publisher = self.$center
//        myLocationPublisher.sink{[weak self] output in
//            self?.requestNearDisease()
//        }
//        .store(in: &subscription)
    }
}

