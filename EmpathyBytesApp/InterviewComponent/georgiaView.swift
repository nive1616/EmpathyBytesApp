//
//  georgiaView.swift
//  test
//
//  Created by Molly Brigham on 10/28/20.
//
//This view represents the interview page with Lara Langston
import SwiftUI
import AVKit

struct georgiaView: View {
    var body: some View {
        georgiaPlayer()
    }
}

struct georgiaView_Previews: PreviewProvider {
    static var previews: some View {
        georgiaView()
    }
}

struct georgiaPlayer : View {
    @State var data : Data = .init(count: 0)
    @State var title = ""
    @State var player : AVAudioPlayer!
    @State var playing = false
    @State var width : CGFloat = 0
    @State var songs = ["dickAudio"]
    @State var current = 0
    @State var finish = false
    @State var del = AVdelegateGeorgia()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    var body : some View{
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.init(red: 249/255, green: 246/255, blue: 231/255), .init(red: 249/255, green: 246/255, blue: 231/255)]), startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        
            Text("")
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action : {
                    self.player.pause()
                    self.playing = false
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Image(systemName: "arrow.left")
                })
            VStack(spacing: 40) { // Information stack
                Text("Lara Langston")
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .foregroundColor(.init(red: 0/255, green: 48/255, blue: 87/255))
                    .padding(.top)
                VStack(spacing: 10) {
                    Image(uiImage: self.data.count == 0 ? UIImage(named: "logoCircuitsTech")! : UIImage(data: self.data)!)
                        .resizable()
                        .frame(width: self.data.count == 0 ? 150 : nil, height: 150)
                        .cornerRadius(15)
                        .padding()
                    Text("Lara Langston is from Ringgold, a town home to just over 3500 residents. Ringgold is a prime example of small town Georgia, where its residents live in a close-knit community.")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(.init(red: 0/255, green: 48/255, blue: 87/255))
                        .padding()
                    Text(self.title).font(.title).padding(.top)
    //
                        ZStack(alignment: .leading) {
                        
                            Capsule().fill(Color.black.opacity(0.08)).frame(height: 8)
                            
                            Capsule().fill(Color.init(red: 0/255, green: 48/255, blue: 87/255)).frame(width: self.width, height: 8)
                            .gesture(DragGesture()
                                .onChanged({ (value) in
                                    
                                    let x = value.location.x
                                    
                                    self.width = x
                                    
                                }).onEnded({ (value) in
                                    
                                    let x = value.location.x
                                    
                                    let screen = UIScreen.main.bounds.width - 30
                                    
                                    let percent = x / screen
                                    
                                    self.player.currentTime = Double(percent) * self.player.duration
                                }))
                        }
                        .padding(.top)
                
                HStack(spacing: UIScreen.main.bounds.width / 5 - 30){
                    
                    
                        Button(action: { //this button goes back 15 seconds in the audio
                            
                            self.player.currentTime -= 15
                            
                        }) {
                    
                            Image(systemName: "gobackward.15").font(.title)
                            
                        }
                    
                        Button(action: { //this button pauses and unpauses the audio
                            
                            if self.player.isPlaying{
                                
                                self.player.pause()
                                self.playing = false
                            }
                            else{
                                
                                if self.finish{
                                    
                                    self.player.currentTime = 0
                                    self.width = 0
                                    self.finish = false
                                    
                                }
                                
                                self.player.play()
                                self.playing = true
                            }
                            
                        }) {
                    
                            Image(systemName: self.playing && !self.finish ? "pause.fill" : "play.fill").font(.title)
                            
                        }
                    
                        Button(action: { //this button increments the time by 15 seconds
                           
                            let increase = self.player.currentTime + 15
                            
                            if increase < self.player.duration{
                                
                                self.player.currentTime = increase
                            }
                            
                        }) {
                    
                            Image(systemName: "goforward.15").font(.title)
                            
                        }
                    
                }.padding(.top,25)
                .foregroundColor(.black)
                
            }.padding()
            .onAppear {
                
                let url = Bundle.main.path(forResource: self.songs[self.current], ofType: "mp3")
                
                self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
                
                self.player.delegate = self.del
                
                self.player.prepareToPlay()
                self.getData()
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                    
                    if self.player.isPlaying{
                        
                        let screen = UIScreen.main.bounds.width - 30
                        
                        let value = self.player.currentTime / self.player.duration
                        
                        self.width = screen * CGFloat(value)
                    }
                }
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
                    
                    self.finish = true
                }
            }
            
            }
                }

                
    }
    
    
    func getData(){
        
        
        let asset = AVAsset(url: self.player.url!)
        
        for i in asset.commonMetadata{
            
            if i.commonKey?.rawValue == "artwork"{
                
                let data = i.value as! Data
                self.data = data
            }
            
            if i.commonKey?.rawValue == "title"{
                
                let title = i.value as! String
                self.title = title
            }
        }
    }
    
}

class AVdelegateGeorgia : NSObject,AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}
