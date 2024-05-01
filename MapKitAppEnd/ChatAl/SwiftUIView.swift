//
//  SwiftUIView.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 1.05.2024.
//

import SwiftUI
import Combine

struct SwiftUIView: View {
    @State var chatMessages: [ChatMessage] = []
    @State var messageText: String = ""
    @State var cancelLables = Set<AnyCancellable>()
    let openAIService = OpenAIService()
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(chatMessages, id: \.id) { message in
                        messageView(message: message)
                    }
                }
                HStack {
                    TextField("Enter a message", text: $messageText) {
                        
                    }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(12)
                    Button {
                        sendMessage()
                    } label: {
                        Text("Send")
                            .foregroundColor(.white)
                            .padding()
                            .background(.black)
                            .cornerRadius(12)
                    }
                }
                
            }
            .padding()
            
        }
        
    }
    func messageView(message: ChatMessage) -> some View {
        
        HStack {
            if message.sender == .me { Spacer() }
            Text(message.content)
                .foregroundColor(message.sender == .me ? .white : .black)
                .padding()
                .background(message.sender == .me ? .blue : .gray.opacity(0.1))
            .cornerRadius(16)
            if message.sender == .gbt { Spacer() }
        }
    }
    func sendMessage() {
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAIService.sendMessage(message: messageText).sink { completion in
        } receiveValue: {  response in
            guard let textResponse =
                    response.choices.first?.text.trimmingCharacters(in:
                            .whitespacesAndNewlines.union(.init(charactersIn: "\"" ))) else { return }
            let gbtMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gbt)
            chatMessages.append(gbtMessage)
        }
        .store(in: &cancelLables)
        messageText = ""
        
    }
}

#Preview {
    SwiftUIView()
}
struct ChatMessage {
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
    
}
enum MessageSender {
    case me
    case gbt
}
extension ChatMessage {
    static let sampleMessages = [
        ChatMessage(id: UUID().uuidString, content: "Sample Message From me", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sample Message From gbt", dateCreated: Date(), sender: .gbt),
        ChatMessage(id: UUID().uuidString, content: "Sample Message From me", dateCreated: Date(), sender: .me),
        ChatMessage(id: UUID().uuidString, content: "Sample Message From gbt", dateCreated: Date(), sender: .gbt)
    ]
}

