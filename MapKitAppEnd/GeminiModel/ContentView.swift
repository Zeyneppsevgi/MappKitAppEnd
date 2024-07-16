//
//  APIKey.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 8.05.2024.
//

import SwiftUI
import GoogleGenerativeAI

struct ContentView: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    
    @State private var textInput = ""
    @State private var aiResponse = ""
    @State private var logoAnimating = false
    @State private var timer: Timer?
    
    @State private var chatHistory: [String] = []
    @State private var suggestedPlaces: [String] = []
    
    var body: some View {
        VStack {
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
    
    func sendMessage() {
        guard !textInput.isEmpty else { return }
        
        Task {
            do {
                startLoadingAnimation()
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
    
    func processResponse(_ response: String) {
        let suggestions = response.components(separatedBy: ",")
        suggestedPlaces = suggestions
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

