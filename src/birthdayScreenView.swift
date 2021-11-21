//
//  birthdayScreenView.swift
//  birthday
//
//  Created by Yoav Paskaro on 16/11/2021.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { gr in
            Color.clear
            .preference(key: SizePreferenceKey.self, value: gr.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct birthdayScreenView: View {
    private let backgroundImage: Image
    private let leftSwirlsImage: Image
    private let rightSwirlsImage: Image
    private let nanitLogoImage: Image
    private let shareButtonText: String
    private let shareButtonImage: Image
    
    private var ageTextPrefix: String = ""
    private var ageTextSuffix: String = ""
    private var ageImage: Image?
    private var cameraIconUIImage: UIImage?
    private var cameraIconImage: Image?
        
    @State private var birthdayDetails = BirthdayDetails(name: "", years: 0, months: 0)
    @State private var babyUIImage: UIImage?
    @State private var babyImage: Image?
    @State private var cameraIconX: CGFloat?
    @State private var cameraIconY: CGFloat?
    @State private var babyImageWidth = 0.0
    @State private var babyImageHeight = 0.0
    @State private var shouldShowImagePicker = false
    @State private var shouldShowActionScheet = false
    @State private var shouldShowCamera = false
    @State private var shouldShareImage = false

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    init(birthdayDetails: BirthdayDetails) {
        self.init()
        self.birthdayDetails = birthdayDetails
        
        let name = birthdayDetails.name
        ageTextPrefix = "TODAY " + name + " IS"
        var timeUnitsName: String
        var timeUnitsNumber: Int
        let years = birthdayDetails.years
        var months = birthdayDetails.months
        // for baby that was born this month we'll ceil to 1 month for display purpose (since there is no days resolution)
        if (years == 0 && months == 0) {
            months = 1
        }
        if (years == 0) {
            timeUnitsName = "MONTH"
            timeUnitsNumber = months
        } else {
            timeUnitsName = "YEAR"
            timeUnitsNumber =  years
        }
        ageTextSuffix = timeUnitsName + " OLD!"
        ageImage = Image(String(timeUnitsNumber))
        
        babyUIImage = birthdayDetails.babyUIImage ?? UIImage(named: "defaultPlaceHolderBlue")
        guard let wrappedbabyUIImage = babyUIImage else {
            return
        }
        babyImage = Image(uiImage: wrappedbabyUIImage)
    }
    
    init() {
        // TODO: implement ABC Test
        backgroundImage = Image("iOsBgElephant")
        leftSwirlsImage = Image("leftSwirls")
        rightSwirlsImage = Image("rightSwirls")
        nanitLogoImage = Image("nanitLogo")
        shareButtonText = "Share the news"
        shareButtonImage = Image("shareWhiteSmall")
        
        cameraIconUIImage = UIImage(named: "cameraIconBlue")
        cameraIconImage = (cameraIconUIImage != nil) ? Image(uiImage: cameraIconUIImage!) : nil
    }
    
    var btnBack : some View {
        Button(action: {
        presentationMode.wrappedValue.dismiss()
        }) {
            Image("arrowBackBlue")
        }
    }

    var ageTextSectionView: some View {
        VStack(spacing:0) {
            Text(ageTextPrefix)
                .frame(width: 226, height: 50, alignment: .center)
                .padding(.bottom, 13)
            HStack(spacing: 0) {
                leftSwirlsImage
                    .padding(.trailing, 22)
                ageImage
                    .padding(.trailing, 22)
                rightSwirlsImage
            }
            .padding(.bottom, 14)
            Text(ageTextSuffix)
                .frame(width: 226, height: 25, alignment: .center)
        }
    }
    
    var babyImageView: some View {
        babyImage?
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .clipShape(Circle())
            .clipped()
            .modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {size in
                babyImageWidth = size.width
                babyImageHeight = size.height
                calcCameraIconX()
                calcCameraIconY()
            }
    }
    var cameraIconImageView: some View {
        cameraIconImage
            .offset(x: cameraIconX ?? 0.0, y: cameraIconY ?? 0.0)
            .onTapGesture {
                shouldShowActionScheet = true
            }
            .opacity(shouldShareImage ? 0 : 1)
    }
    
    var logoImageView: some View {
        nanitLogoImage
            .padding(.bottom, 20)
    }
    
    var shareButtonView: some View {
        Button(action: share) {
            Text(shareButtonText)
                .font(Fonts.regular)
                .foregroundColor(.white)
                .padding(.leading, 21)
                .padding(.vertical, 11)
            shareButtonImage.renderingMode(.original)
                .padding(.trailing, 5)
        }
        .background(Capsule().fill(Colors.blush))
        .opacity(shouldShareImage ? 0 : 1)
    }
    
    var spaceView: some View {
        VStack(spacing:0) {
            EmptyView()
        }
        .frame(minHeight: 20, maxHeight: .infinity)
    }
    
    var bottomSpaceView: some View {
        VStack(spacing:0) {
            EmptyView()
        }
        .frame(minHeight: 80, maxHeight: .infinity)
    }

    var body: some View {
        ScrollView {
            ZStack {
                backgroundImage
                    .resizable().scaledToFill()
                VStack(spacing:0) {
                    spaceView
                    ageTextSectionView
                    spaceView
                    ZStack {
                        babyImageView
                        cameraIconImageView
                    }
                    .padding(.bottom, 15)
                    .padding(.horizontal, 50)
                    logoImageView
                    shareButtonView
                    bottomSpaceView
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: btnBack)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(shouldShareImage)
            }
        }
        .actionSheet(isPresented: $shouldShowActionScheet) { () -> ActionSheet in
            ActionSheet(title: Text("Please choose mode"), buttons: [ActionSheet.Button.default(Text("Camera"), action: {
                shouldShowImagePicker = true
                shouldShowCamera = true
            }), ActionSheet.Button.default(Text("Photo Library"), action: {
                shouldShowImagePicker = true
                shouldShowCamera = false
            }), ActionSheet.Button.cancel()])
        }
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: imageSelected) {
            ImagePickerView(sourceType: shouldShowCamera ? .camera : .photoLibrary, image: $babyUIImage, isPresented: $shouldShowImagePicker)
        }
    }
    
    func calcCameraIconX() {
        if (cameraIconX != nil) {
            return
        }
        cameraIconX = babyImageWidth/2 * sin(Double.pi/4) // x = radius * sin(angle)
    }
    
    func calcCameraIconY() {
        if (cameraIconY != nil) {
            return
        }
        cameraIconY = -babyImageWidth/2 * cos(Double.pi/4) // y = - radius * cos(angle)
    }
    
    func imageSelected() {
        displayImage()
        saveImage(babyUIImage: babyUIImage)
    }
    
    func displayImage() {
        guard let wrappedBabyUIImage = babyUIImage else {
            return
        }
        babyImage = Image(uiImage: wrappedBabyUIImage)
    }
    
    func share() {
        shouldShareImage = true
        let processedImage = body.snapshot()
        let activityVC = UIActivityViewController(activityItems: [processedImage], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: {
            shouldShareImage = false
        })
    }
}

struct birthdayScreenView_Previews: PreviewProvider {
    static var previews: some View {
        birthdayScreenView()
    }
}
