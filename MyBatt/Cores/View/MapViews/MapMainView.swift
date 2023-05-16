//
//  MapMainView.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/04.
//

import SwiftUI
import NativePartialSheet
struct MapMainView: View {
    @EnvironmentObject var appManager: AppManager
    @State var isPresent = false
    @State var detent: Detent = .height(70)
    var body: some View {
        ZStack{
            KakaoMapViewWrapper()
                .ignoresSafeArea()
                .sheet(isPresented: $isPresent){
                    MapSheetView()
                }
                .presentationDetents([.large,.height(70)],selection: $detent)
                .cornerRadius(16)
                .presentationDragIndicator(.hidden)
                .sheetColor(.clear)
                .edgeAttachedInCompactHeight(true)
                .scrollingExpandsWhenScrolledToEdge(true)
                .widthFollowsPreferredContentSizeWhenEdgeAttached(true)
                .largestUndimmedDetent(.height(70))
                .interactiveDismissDisabled(false,
                                            onWillDismiss: {
                    print("willDismiss")
                },
                                            onDidDismiss: {
                    print("isDismissed")
                })
                
        }
        .onTapGesture {
            isPresent.toggle()
        }
        .onAppear(){
            appManager.isTabbarHidden = true
        }
        .onDisappear(){
            withAnimation(.easeOut(duration: 0.2)) {
                appManager.isTabbarHidden = false
                
            }
            let isPresented = false
            guard let window = UIApplication.shared.keyWindow else { return }
            guard let rootViewController = window.rootViewController else { return }
            let presentedViewController = rootViewController.presentedViewController
            rootViewController.dismiss(animated: false)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    self.isPresent = false
                    appManager.goRootView()
                } label: {
                    HStack(spacing:4){
                        Image(systemName: "chevron.left").font(.headline)
                        Text("Back")
                    }
                }.padding(.horizontal, -8)
            }
            ToolbarItem(placement: .principal) {
                Text("경기도 구리시 인창동")
                    .fontWeight(.semibold)
            }
        }
    }
}

struct MapMainView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapMainView().environmentObject(AppManager())
        }
    }
}
