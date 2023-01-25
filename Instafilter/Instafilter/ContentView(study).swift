//
//  ContentView.swift
//  Instafilter
//
//  Created by Gorkem Turan on 10.01.2023.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentViewStudy: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
            
            Button("Select Image") {
                showingImagePicker = true
            }
            
            Button("Save Image") {
                guard let inputImage = inputImage else { return }

                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: inputImage)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in loadImage() }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        UIImageWriteToSavedPhotosAlbum(inputImage, nil, nil, nil)
    }

}

//func loadImage() {
//    guard let inputImage = UIImage(named: "Example") else { return }
//    let beginImage = CIImage(image: inputImage)
//
//    let context = CIContext()
//    let currentFilter = CIFilter.twirlDistortion()
//    currentFilter.inputImage = beginImage
//
//    let amount = 1.0
//
//    let inputKeys = currentFilter.inputKeys
//
//    if inputKeys.contains(kCIInputIntensityKey) {
//        currentFilter.setValue(amount, forKey: kCIInputIntensityKey) }
//    if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey) }
//    if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey) }
//
//    // get a CIImage from our filter or exit if that fails
//    guard let outputImage = currentFilter.outputImage else { return }
//
//    // attempt to get a CGImage from our CIImage
//    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
//        // convert that to a UIImage
//        let uiImage = UIImage(cgImage: cgimg)
//
//        // and convert that to a SwiftUI image
//        image = Image(uiImage: uiImage)
//    }
//
//}

struct ContentViewStudy_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
