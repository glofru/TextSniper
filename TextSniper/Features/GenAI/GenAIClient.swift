//
//  GenAIClient.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-30.
//

import Foundation

enum GenAIClientError: Error {
    case expiredToken
    case clientFailure
    case genericError(String)
}

extension GenAIClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .clientFailure:
            "Client failure"
        case .expiredToken:
            "Expired token"
        case let .genericError(error):
            "Generic error: \(error)"
        }
    }
}

enum GenAIModel {
    case fast
    case smart
}

struct GenAIResponse {
    let text: String
}

protocol GenAIClient: Sendable {
    init?()

    func initModels() async throws(GenAIClientError)

    func input(text: String, model: GenAIModel) -> AsyncThrowingStream<GenAIResponse, Error>
}
