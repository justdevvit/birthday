//
//  ContentView.swift
//  birthday
//
//  Created by Yoav Paskaro on 15/11/2021.
//

import SwiftUI

struct BirthdayDetails {
    var name: String
    var years: Int
    var months: Int
    var babyUIImage: UIImage?
}

struct ContentView: View {
    private let appText: String = "Happy Birthday!"
    private let endDate = Date()

    private var startDate: Date?
    
    @State private var birthdayDetails: BirthdayDetails = BirthdayDetails(name: "", years: 0, months: 0)
    @State private var name = ""
    @State private var date = Date.distantFuture
    @State private var shouldShowImagePicker = false
    @State private var shouldShowActionScheet = false
    @State private var shouldShowCamera = false
    @State private var didCancelImagePicker = false
    @State private var babyUIImage: UIImage?
    @State private var babyImage: Image?
    @State private var shouldShowBirthdayScreen = false

    init() {
        restoreData()
        updateDatePickerRange()
    }
    
    var appNameView: some View {
        Text(appText)
    }
    
    var nameView: some View {
        TextField("Please type in the baby name", text:$name)
            .padding(.bottom)
            .multilineTextAlignment(TextAlignment.center)
            .onChange(of: name) {newValue in
                saveName(name: newValue)
            }
    }
    
    var datePickerTitleView: some View {
        Text("Please update Birthday:")
    }
    
    var datePickerView: some View {
        DatePicker("", selection: $date,  in: ((startDate ?? Date())...endDate), displayedComponents: .date)
            .padding(.bottom)
            .datePickerStyle(GraphicalDatePickerStyle())
            .onChange(of: date) {newValue in
                saveDate(date: newValue)
            }
    }
    
    var uploadPictureButtonView: some View {
        Button("Tap to upload a picture", action: {
            shouldShowActionScheet = true
        })
    }
    
    var babyImageView: some View {
        babyImage?.resizable().scaledToFill().clipped()
    }
    
    var showBirthdayScreenButtonView: some View {
        Button("Show birthday screen", action: showBirthdayScreen)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing:0) {
                    Spacer()
                    Divider()
                    appNameView
                        .padding(.vertical)
                    nameView
                    datePickerTitleView
                    datePickerView
                    uploadPictureButtonView
                    babyImageView
                    showBirthdayScreenButtonView
                        .padding(.vertical)
                        .disabled(name.isEmpty || date == Date.distantFuture)
                    
                    NavigationLink(
                                destination: birthdayScreenView(birthdayDetails: birthdayDetails),
                                isActive: $shouldShowBirthdayScreen
                            ) {
                    }
                }
                .navigationBarHidden(true)
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
            ImagePickerView(sourceType: shouldShowCamera ? .camera : .photoLibrary, image: $babyUIImage, isPresented: $shouldShowImagePicker, didCancel: $didCancelImagePicker)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // baby period is until 3 age old, so we limit the birthday to 3 years ago max
    mutating func updateDatePickerRange() {
        let oneDayInSec: TimeInterval = 86400
        let oneYearInSec: TimeInterval = oneDayInSec * 365 // add one more day so 3 year old will be included in the range and won't be out of boundaries
        let birthdateRange = oneYearInSec * 3 + oneDayInSec
        startDate = endDate.addingTimeInterval(-birthdateRange)
    }
    
    func showBirthdayScreen() {
        let today = Date()
        let age = Calendar.current.dateComponents([.year, .month, .day], from: date, to: today)
        shouldShowBirthdayScreen = true
        birthdayDetails = BirthdayDetails(name: name, years: age.year ?? 0, months: age.month ?? 0, babyUIImage: babyUIImage)
    }
    
    func imageSelected() {
        if (didCancelImagePicker) {
            return
        }
        displayImage()
        saveImage(babyUIImage: babyUIImage)
    }
    
    func displayImage() {
        guard let wrappedBabyUIImage = babyUIImage else {
            return
        }
        babyImage = Image(uiImage: wrappedBabyUIImage)
    }

    // Restore Data
    mutating func restoreData() {
        restoreName()
        restoreDate()
        restoreImage()
    }
    
    mutating func restoreName() {
        if let name: String = loadName() {
            _name = State(initialValue: name)
        } else {
            print("load name failed")
        }
    }
    
    mutating func restoreDate() {
        if let date: Date = loadDate() {
            _date = State(initialValue: date)
        } else {
            print("load date failed")
        }
    }
    
    mutating func restoreImage() {
        if let loadedImage: UIImage = loadImage() {
            _babyUIImage = State(initialValue: loadedImage)
            if (babyUIImage != nil) {
                _babyImage = State(initialValue:Image(uiImage: babyUIImage!))
            }
            else {
                print("load Image failed")
            }
        }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
