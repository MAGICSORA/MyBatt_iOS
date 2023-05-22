//
//  TakenPhotoView.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/03.
//

import SwiftUI
import Foundation

struct CropTypePhoto:Identifiable,Hashable{
    var id = UUID()
    let icon: String
    let name: String
}
struct TakenPhotoView: View {
    let screenWidth = UIScreen.main.bounds.width
    @EnvironmentObject var cameraModel: CameraViewModel
    @EnvironmentObject var appManager: AppManager
    @StateObject var takenVM: TakenPhotoVM = TakenPhotoVM(lastCropType: .Lettuce)
    @Binding var takenView: Bool
    @State var stopToTaking = true
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 170)),GridItem(.adaptive(minimum: 170))
    ]
    
    var body: some View {
        ZStack{
            if let image = cameraModel.takenImage {
                imageAppearView(image:image
                                //Image("picture_demo")
                )
                .onAppear(){
                    takenVM.selectedCropType = appManager.lastCropType
                }
                .onDisappear(){
                    // 여기 유저 모델로 수정할 필요 있음
                    appManager.lastCropType = takenVM.selectedCropType
                    cameraModel.takenImage = nil
                }
            }else{
                ProgressView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    self.takenView = false
                } label: {
                    HStack(spacing:4){
                        Image(systemName: "chevron.left").font(.headline)
                        Text("Back")
                    }
                }.padding(.horizontal, -8)
                    .disabled(stopToTaking)
            }
            ToolbarItem(placement: .principal) {
                Text("\(cameraModel.address ?? "")")
                    .fontWeight(.semibold)
            }
        }
        .disabled(stopToTaking)
        .onAppear(){
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                stopToTaking = false
            }
        }
        .onDisappear(){
            cameraModel.locationService.address = nil
        }
    }
    func imageAppearView(image:Image)-> some View{
        VStack{
            VStack(spacing:10){
                image.resizable().scaledToFill()
                ScrollView{
                    LazyVGrid(columns: adaptiveColumns,spacing: 20) {
                        ForEach(takenVM.crops, id:\.self){ crop in
                            Button{
                                takenVM.selectedCropType = crop.cropType
                            }label:{
                                Label {
                                    Text(crop.name)
                                        .font(.title3)
                                } icon: {
                                    Text(crop.icon)
                                        .imageScale(.large)
                                        .font(.title3)
                                }
                                .frame(width: screenWidth/3)
                                .padding(.vertical,15)
                                .modifier(SelectedModifier(isSelected: crop.cropType == takenVM.selectedCropType))
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            Spacer()
            self.takenBtnView
        }
    }
    var takenBtnView: some View{
        HStack{
            Spacer()
            ImageAppeaerBtnView(btnAction: {
                takenView = false
            }, labelText: "다시 촬영하기", iconName: "arrowshape.turn.up.backward",bgColor: .red)
            Spacer()
            ImageAppeaerBtnView(btnAction: {
                cameraModel.saveImageToAlbum()
                takenView = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    appManager.cameraRunning(isRun: false)
                }
            }, labelText: "전송하기", iconName:
                                    "paperplane", bgColor: .accentColor)
            Spacer()
        }
    }
}

fileprivate struct SelectedModifier: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        if isSelected{
            content
                .foregroundColor(.accentColor)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .background(RoundedRectangle(cornerRadius: 15).stroke(lineWidth:5).foregroundColor(.accentColor))
        }else{
            content
                .foregroundColor(
                    .black
                )
                .background(Color.white)
                .cornerRadius(15)
                .background(RoundedRectangle(cornerRadius: 15).stroke(
                    lineWidth:3
                ).foregroundColor(.black))
        }
    }
}


struct TakenPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        TakenPhotoView(takenView: .constant(true))
            .environmentObject(CameraViewModel())
            .environmentObject(AppManager())
    }
}
