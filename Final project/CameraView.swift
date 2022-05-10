//
//  Camera View.swift
//  Final project
//
//  Created by BOLT on 10/05/2022.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View{
        
        ZStack{
            
            // Going to Be Camera preview...
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                if camera.isTaken{
                    
                    HStack {
                        
                        Spacer()
                        
                        Button(action: camera.reTake, label: {

                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing,10)
                    }
                }
                
                Spacer()
                
                HStack{
                    
                    if camera.isTaken{
                        
                        Button(action: {if !camera.isSaved{camera.sendPicData()}}, label: {
                            Text(camera.isSaved ? "Saved" : "Save")
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
                                .padding(.vertical,10)
                                .padding(.horizontal,20)
                                .background(Color.white)
                                .clipShape(Capsule())
                        })
                        .padding(.leading)
                        
                        Spacer()
                    }
                    else{
                        
                        Button(action: camera.takePic, label: {
                            
                            ZStack{
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                
                                Circle()
                                    .stroke(Color.white,lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        })
                    }
                }
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            
            camera.Check()
        })
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
        .sheet(isPresented: $camera.isShowingPossibleResults) {
            List {
                HStack {
                    Text("Name")
                    Spacer()
                    Text("Accuracy")
                }
                .padding()
                ForEach(camera.clarifai, id: \.self){ result in
                    Button {
                        camera.isShowingPossibleResults = false
                        viewModel.isShowingCamera = false
                        fetch(searchTerm: result.name)
                        
                    } label: {
                        HStack {
                            Text(result.name)
                                .foregroundColor(.purple)
                            Spacer()
                            Text("\(result.value * 100, specifier: "%.2f") %")
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
            
        }
    }
    
    func fetch(searchTerm: String){
        
        let url = URL(string: "https://trackapi.nutritionix.com/v2/search/instant?query=\(searchTerm)")

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.setValue("48c5d2b3", forHTTPHeaderField:"x-app-id")
        request.setValue("274757a70dbb78be6611d630f168f4fe", forHTTPHeaderField:"x-app-key")
        request.setValue("0", forHTTPHeaderField:"x-remote-user-id")
        request.timeoutInterval = 60.0
        
        let task = URLSession.shared.dataTask(with: request) { data, _,
            error in
            guard let data = data, error == nil else{
                return
            }
            
            do {
                let nutritions = try JSONDecoder().decode(NutritionResponse.self, from: data)
                DispatchQueue.main.async {
                    viewModel.nutritions = nutritions.branded
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }
}



class CameraModel: NSObject,ObservableObject,AVCapturePhotoCaptureDelegate{
    
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    // since were going to read pic data....
    @Published var output = AVCapturePhotoOutput()
    
    // preview....
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    // Pic Data...
    
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    @Published var clarifai = [ClarifaiConcepts]()
    @Published var isShowingPossibleResults = false
    
    
    func Check(){
        
        // first checking camerahas got permission...
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
            // Setting Up Session
        case .notDetermined:
            // retusting for permission....
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                
                if status{
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
            
        default:
            return
        }
    }
    
    func setUp(){
        
        // setting up camera...
        
        do{
            
            // setting configs...
            self.session.beginConfiguration()
            
            // change for your own...
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            // checking and adding to session...
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            // same for output....
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    // take and retake functions...
    
    func takePic(){
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                    self.session.stopRunning()
                }
            }
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
            print("pic taken...")
        }
    }
    
    func reTake(){
        
        DispatchQueue.global(qos: .background).async {
            
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                //clearing ...
                self.isSaved = false
                self.picData = Data(count: 0)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if error != nil{
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else{return}
        self.picData = imageData
    }
    
    func savePic(){
        
        guard let image = UIImage(data: self.picData) else{return}
        
        // saving Image...
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("saved Successfully....")
    }
    
    func sendPicData(){
        let image = UIImage(data: self.picData)
        let imageData: Data = image?.jpegData(compressionQuality: 0.1) ?? Data()
        let imageString: String = imageData.base64EncodedString()
        let dictionary: Request = Request(inputs: [CInput(data: CDataClass(image: CImage(base64: imageString)))])
        if let theJSONData = try? JSONEncoder().encode(dictionary) {
            guard let sendURL = URL(string:"https://api.clarifai.com/v2/models/bd367be194cf45149e75f01d59f77ba7/outputs") else {
                print("invalid URL")
                return
            }
            var request = URLRequest(url: sendURL)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Key bbfd4a7959344e369fd62986f81fac42", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = theJSONData
            let task = URLSession.shared.dataTask(with: request) { data, _,
                error in
                guard let data = data, error == nil else{
                    return
                }
                do {
                    let response = try JSONDecoder().decode(ClarifaiResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.clarifai = response.outputs[0].data.concepts
                        self.isShowingPossibleResults = true
                    }
                }
                catch {
                    print(error)
                }
                
            }
            
            task.resume()

        }
    }
}



struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // Your Own Properties...
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // starting session
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
