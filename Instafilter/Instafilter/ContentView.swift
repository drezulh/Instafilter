//
//  ContentView.swift
//  Instafilter
//
//  Created by Gorkem Turan on 11.01.2023.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    @State private var filterSaturationAmount = 0.0
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    @State private var processedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                HStack {
                    VStack {
                        Text("Intensity")
                            .foregroundColor(!currentFilter.inputKeys.contains(kCIInputIntensityKey) ? .gray: .black)
                        Slider(value: $filterIntensity)
                            .disabled(!currentFilter.inputKeys.contains(kCIInputIntensityKey))
                            .onChange(of: filterIntensity) { _ in
                                applyProcessing()
                            }
                        Text("Radius")
                            .foregroundColor(!currentFilter.inputKeys.contains(kCIInputRadiusKey) ? .gray: .black)
                        Slider(value: $filterRadius)
                            .disabled(!currentFilter.inputKeys.contains(kCIInputRadiusKey))
                            .onChange(of: filterRadius) { _ in
                                applyProcessing()
                            }
                        Text("Scale")
                            .foregroundColor(!currentFilter.inputKeys.contains(kCIInputScaleKey) ? .gray: .black)
                        Slider(value: $filterScale)
                            .disabled(!currentFilter.inputKeys.contains(kCIInputScaleKey))
                            .onChange(of: filterScale) { _ in
                                applyProcessing()
                            }
                        Text("Saturation Amount")
                            .foregroundColor(!currentFilter.inputKeys.contains(kCIInputAmountKey) ? .gray: .black)
                        Slider(value: $filterSaturationAmount, in: -1.0...1.0)
                            .disabled(!currentFilter.inputKeys.contains(kCIInputAmountKey))
                            .onChange(of: filterSaturationAmount) { _ in
                                applyProcessing()
                            }
                        
                    }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        // change filter
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    
                    Button("Save", action: save)
                        .disabled(inputImage == nil)
                    
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage, perform: { _ in loadImage() })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                VStack{
                    Group {
                        Button("Comic Effect") {setFilter(CIFilter.comicEffect()) }
                        //comic use no parameter
                        Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                        Button("Edges") { setFilter(CIFilter.edges()) }
                        Button("Dither") {setFilter(CIFilter.dither()) }
                        //dither use intensity
                        Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    }
                    Group {
                        Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                        Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                        Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                        Button("Vibrance") {setFilter(CIFilter.vibrance()) }
                        //vibrance use amount parameter
                        Button("Vignette") { setFilter(CIFilter.vignette()) }
                    }
                    Button("Cancel", role: .cancel) { }
                    
                }
            }
            
        }
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
