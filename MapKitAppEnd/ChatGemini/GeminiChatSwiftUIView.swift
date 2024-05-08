//
//  GeminiChatSwiftUIView.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 8.05.2024.
//

import SwiftUI
import GoogleGenerativeAI

struct GeminiChatSwiftUIView: View {
    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    
    @State var textInput = ""
    @State var aiResponse = "Hello! how can ı help you today?"
    @State var logoAnimating = false
    @State var timer: Timer?
    
    var body: some View {
        VStack {
            Image(.geminiLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .opacity(logoAnimating ? 0.5 : 1)
                .animation(.easeInOut, value: logoAnimating)
            
            ScrollView {
                Text(aiResponse)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                TextField("enter a message", text: $textInput)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.black)
                Button (action: sendMessage, label: {
                    Image(systemName: "paperplane.fill")

               
                })

            }
        }
        .foregroundColor(.white)
        .padding()
        .background {
            ZStack {
                Color.black
            }
            .ignoresSafeArea()
        }
    }
    func sendMessage() {
        aiResponse =  ""
        Task {
            do {
                let response = try await model.generateContent(textInput)
                stopLoadingAnimation()
                guard let text = response.text else {
                    textInput = "sorry, ı could not process that. \n please try again"
                    return
                }
                textInput = ""
                aiResponse = text
            } catch {
                stopLoadingAnimation()
                aiResponse = "Somethin went wrong.\n \(error.localizedDescription)"
            }
            
        
        }
    }
    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            logoAnimating.toggle()
        })
    }
    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    GeminiChatSwiftUIView()
}
