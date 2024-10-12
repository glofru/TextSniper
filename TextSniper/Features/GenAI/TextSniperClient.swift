//
//  TextSniperClient.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-10-08.
//

import Foundation

actor TextSniperClient {
    let client: GenAIClient

    init() async throws(GenAIClientError) {
        guard let client = AWSClient() else {
            throw .genericError("Failed to initialize the client")
        }

        self.client = client

        try await self.client.initModels()
    }

    func summarize(text: String) -> AsyncThrowingStream<GenAIResponse, Error> {
        client.input(text: "Summarize, in a few sentences, the following text:\n\n```\n\(text)\n```", model: .fast)
    }
}
