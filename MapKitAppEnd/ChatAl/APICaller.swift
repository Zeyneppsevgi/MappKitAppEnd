//
//  APICaller.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 1.05.2024.
//
import OpenAISwift
import Foundation

final class APICaller {
    static let shared = APICaller()
    
    @frozen enum Constants {
        static let key = "sk-proj-oacwfFkIVwFoOhxbjrfNT3BlbkFJht8rlg7xdZM1zwUGXdjZ"
    }
    
    private var client: OpenAISwift?
    
    private init() {}
    
    public func setup() {
        self.client = OpenAISwift(config: OpenAISwift.Config.makeDefaultOpenAI(apiKey: Constants.key))
    }
    
    public func getResponse(input: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        client?.sendCompletion(with: input,model: .codex(.davinci), completionHandler: { result in
            switch result {
            case.success(let model):
                print(String(describing: model.choices))
                let output = model.choices?.first?.text ?? ""
                completion(.success(output))
            case.failure(let error):
                completion(.failure(error))
            }
        })
    }
}
