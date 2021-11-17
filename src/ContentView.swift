//
//  ContentView.swift
//  birthday
//
//  Created by Yoav Paskaro on 15/11/2021.
//

import SwiftUI

struct ContentView: View {
    let birthdayImageFileName = "birthday.png"
    let birthdayImageFileNameKey = "birthdayImageFileName"
    let birthdayNameKey = "birthdayName"
    let birthdayDateKey = "birthdayDate"

    
    @State private var name: String = ""
    @State private var date = Date.distantFuture
    @State private var shouldShowImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var shouldShowBirthdayScreen = false
    
    init() {
        restoreData()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                    VStack {
                        Text("Happy Birthday!")
                            .padding(.bottom)
                        
                        TextField("Please type in the baby name", text: $name).padding(.bottom).multilineTextAlignment(TextAlignment.center)
                            .onChange(of: name) {newValue in
                                saveName()
                            }
                        
                        Text("Birthday")
                        DatePicker("", selection: $date,  in: ...Date(), displayedComponents: .date)
                            .padding(.bottom)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onChange(of: date) {newValue in
                                saveDate()
                            }
                        
                        Button(action: {
                            self.shouldShowImagePicker = true
                        }) {
                            Text("Tap to select a picture")
                        }
                        
                        if image != nil {
                            image?.resizable().scaledToFit()
                        }
                        
                        Button("Show birthday screen", action: showBirthdayScreen).padding(.vertical).disabled(name.isEmpty || self.date == Date.distantFuture)
                        
                        NavigationLink(destination: birthdayScreenView(), isActive: self.$shouldShowBirthdayScreen) {}
                    }
                }
                .sheet(isPresented: $shouldShowImagePicker, onDismiss: imageSelected) {
                    ImagePicker(image: $inputImage)
            }
        }
    }
    
    func showBirthdayScreen() {
        let today = Date()
        let diffs = Calendar.current.dateComponents([.year, .month, .day], from: date, to: today)
        
        let ageInYears = diffs.year
        var ageInMonths = diffs.month
        
        // for baby that was born this month we'll ceil to 1 month for display purpose (since there is no days resolution)
        if (ageInYears == 0 && ageInMonths == 0) {
            ageInMonths = 1
        }
        self.shouldShowBirthdayScreen = true
    }
    
    func imageSelected() {
        displayImage()
        saveImage()
    }
    
    func displayImage() {
        guard let wrappedInputImage = self.inputImage else {
            return
        }
        image = Image(uiImage: wrappedInputImage)
    }
    
    // Store Data
    func saveName() {
        UserDefaults.standard.set(self.name, forKey: birthdayNameKey)
    }
    
    func saveDate() {
        UserDefaults.standard.set(self.date, forKey: birthdayDateKey)
    }
    
    func saveImage() {
        // Convert to Data
        if let data = inputImage?.jpegData(compressionQuality: 1.0) {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(birthdayImageFileName)
            
            // Write to Disk
            if (try? data.write(to: url)) != nil {
                // Store image name in User Defaults
                UserDefaults.standard.set(birthdayImageFileName, forKey: birthdayImageFileNameKey)
                print("image saved")
            }
            else {
                print("Unable to Write Data to Disk")
            }
        }
        else {
            print("Unable to Parse image to Data")
        }
    }

    // Restore Data
    mutating func restoreData() {
        loadName()
        loadDate()
        loadImage()
    }
    
    mutating func loadName() {
        if let name: String = UserDefaults.standard.value(forKey: birthdayNameKey) as? String {
            self._name = State(initialValue: name)
        } else {
            print("load name failed")
        }
    }
    
    mutating func loadDate() {
        if let date: Date = UserDefaults.standard.value(forKey: birthdayDateKey) as? Date {
            self._date = State(initialValue: date)
        } else {
            print("load date failed")
        }
    }
    
    mutating func loadImage() {
        if let urlStr = UserDefaults.standard.value(forKey: birthdayImageFileNameKey) {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(urlStr as! String)
            if let data = try? Data(contentsOf: url),
               let loaded = UIImage(data: data) {
                self._image = State(initialValue: Image(uiImage: loaded))
            } else {
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
