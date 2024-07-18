//
//  APIKey.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 8.05.2024.
//
import SwiftUI
import GoogleGenerativeAI
import MapKit
import Foundation

struct ContentView: View {
    
    
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    
    @State private var searchPhrases = ["haritada göster", "yerleri göster", "mekanları göster","göster","listele","sırala"]
    
    @State private var pattern = #"\s*\S+\s+(\d+\.\d+)\s+(\d+\.\d+)\s*"#
    @State private var textInput = ""
    @State private var aiResponse = ""
    @State private var logoAnimating = false
    @State private var timer: Timer?
    
    @State private var chatHistory: [String] = []
    @State private var suggestedPlaces: [String] = []
    
   var onSuggestedPlaces: (([String]) -> Void)?
    
   
    
    var body: some View {
        
        VStack {
            Image("geminiLogo") // Gemimi logosu resmini ekleyin
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .opacity(logoAnimating ? 0.5 : 1)
                            .animation(.easeInOut, value: logoAnimating)
            if !aiResponse.isEmpty {
                // AI'nin cevabını göster
                ChatBubble(message: aiResponse, isUser: false)
            }
            
            ScrollView {
                // AI'den dönen cevapları numaralandırılmış liste olarak gösterme
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(chatHistory, id: \.self) { message in
                        ChatBubble(message: message, isUser: false)
                    }
                    
                    // Öneri listesi
                    if !suggestedPlaces.isEmpty {
                        Divider()
                        
                        Text("Suggestions:")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        List(suggestedPlaces, id: \.self) { place in
                            Text(place)
                        }
                        .listStyle(PlainListStyle())
                        .padding(.horizontal)
                        .frame(maxHeight: 200)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
            HStack {
                TextField("Enter a message...", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.black)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
            }
            .padding()
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            // Uygulama başlatıldığında AI'ye başlangıç mesajı gönderme
            //sendMessage()
        }
    }
    
     func processResponse(_ response: String) {
        let suggestions = response.components(separatedBy: ",")
        suggestedPlaces = suggestions
        
        let combinedString = suggestions.joined()
         print("sonuc:\(combinedString)")
         guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
             print("Invalid regex pattern")
             exit(1)
         }

         // Find matches in the text
         let nsString = combinedString as NSString
         let matches = regex.matches(in: combinedString, options: [], range: NSRange(location: 0, length: nsString.length))

         // Extract coordinates from matches
         var coordinates: [(String, String)] = []

         for match in matches {
             if match.numberOfRanges == 3 {
                 let latitudeRange = match.range(at: 1)
                 let longitudeRange = match.range(at: 2)
                 
                 let latitude = nsString.substring(with: latitudeRange)
                 let longitude = nsString.substring(with: longitudeRange)
                 
                 coordinates.append((latitude, longitude))
             }
         }

         // Print the found coordinates
         print("Bulunan koordinatlar:")
         print(coordinates)
        // Suggested places callback'i çağır
        onSuggestedPlaces?(suggestions)
       
    }
    
    func sendMessage() {
        guard !textInput.isEmpty else { return }
        
        Task {
            do {
                startLoadingAnimation()
                
                print("metin: \(textInput)")
                
                for phrase in searchPhrases {
                    if textInput.contains(phrase) {
                       
                        textInput = textInput + " koordinatları göster"
                    }
                }
                print("metin: \(textInput)")

                let response = try await model.generateContent(textInput)
                stopLoadingAnimation()
                
                guard let text = response.text else {
                    aiResponse = "Sorry, I could not process that.\nPlease try again."
                    return
                }
                
                // AI'den dönen cevabı chat geçmişine ekle
                chatHistory.append(textInput)
                chatHistory.append(text) // AI cevabını da ekleyelim
                
                // AI cevabını işleyerek öneri listesi oluştur
                processResponse(text)
            } catch {
                stopLoadingAnimation()
                aiResponse = "Something went wrong.\n\(error.localizedDescription)"
            }
            
            textInput = "" // Kullanıcı mesajını temizle
        }
    }
    
    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            logoAnimating.toggle()
        }
    }
    
    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
}


struct ChatBubble: View {
    let message: String
    let isUser: Bool
    
    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading) {
            if !isUser {
                Text(message)
                    .padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            } else {
                HStack {
                    Spacer()
                    Text(message)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
