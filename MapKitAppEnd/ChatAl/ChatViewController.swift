import UIKit
import Alamofire
import Combine

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var chatMessages: [ChatMessage] = []
    var cancellables = Set<AnyCancellable>()
    
    let openAIAPIKey = "sk-proj-yxRzPURmSs31mQRwO00aT3BlbkFJAgKuCw7i3J8gs6eWotkR"
    let openAIService = OpenAIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        openAIService.$chatMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.chatMessages = messages
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @IBAction func sendMessage() {
        guard let messageText = messageTextField.text, !messageText.isEmpty else { return }
        let message = ChatMessage(content: messageText, sender: .user)
        chatMessages.append(message)
        messageTextField.text = ""
        
        openAIService.sendMessage(messageText)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let message = chatMessages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        messageLabel.textAlignment = message.sender == .user ? .right : .left
    }
}

struct ChatMessage {
    let content: String
    let sender: Sender
}

enum Sender {
    case user
    case bot
}

class OpenAIService {
    
    @Published var chatMessages: [ChatMessage] = []
    
    func sendMessage(_ message: String) {
        let url = "https://api.openai.com/v1/completions"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Constants.openAIAPIKey)"]
        let body: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": message,
            "temperature": 0.7,
            "max_tokens": 150
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: OpenAIResponse.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let openAIResponse):
                    let botMessage = ChatMessage(content: openAIResponse.choices[0].text, sender: .bot)
                    self.chatMessages.append(botMessage)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
}

struct OpenAIResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let text: String
    }
}

