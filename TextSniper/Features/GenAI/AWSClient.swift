//
//  BedrockClient.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-30.
//

import AWSBedrock
import AWSBedrockRuntime
import Foundation

fileprivate enum AWSRegion: String {
    case usEast1 = "us-east-1"
    case usEast2 = "us-east-2"
    case usWest1 = "us-west-1"
    case usWest2 = "us-west-2"
}

fileprivate enum AWSBedrockProvider: String {
    case anthropic = "anthropic"
}

enum AWSBedrockModel: String {
    case claudeSonnetV3 = "claude-3-sonnet"
    case claudeHaikuV3 = "claude-3-haiku"
    case claudeOpusV3 = "claude-3-opus"
    case claudeSonnetV35 = "claude-3-5-sonnet"
}

class AWSClient: @unchecked Sendable {
    
    private let client: BedrockClient
    private let runtimeClient: BedrockRuntimeClient
    
    private(set) var modelIds: [AWSBedrockModel: String]

    init?() {
        let region = AWSRegion.usWest2.rawValue
        guard let client = try? BedrockClient(config: .init(region: region)) else {
            print("Client failed")
            return nil
        }
        
        guard let runtimeClient = try? BedrockRuntimeClient(config: .init(region: region)) else {
            print("Runtime client failed")
            return nil
        }
        
        self.client = client
        self.runtimeClient = runtimeClient
        self.modelIds = [:]
    }

    func initModels() async {
        do {
            let models = try await client.listFoundationModels(input: ListFoundationModelsInput(byProvider: AWSBedrockProvider.anthropic.rawValue))

            for summary in models.modelSummaries! {
                if summary.modelId?.split(separator: ":").count == 2 {
                    // It's the "normal" model (ex: it's anthropic.claude-3-haiku-20240307-v1:0 instead of anthropic.claude-3-haiku-20240307-v1:0:48k)
                    let modelIdWithoutProvider: String = String(summary.modelId!.split(separator: ".")[1])
                    let bedrockModelId = modelIdWithoutProvider.split(separator: "-").dropLast(2).joined(separator: "-")
                    if let bedrockModel = AWSBedrockModel(rawValue: bedrockModelId) {
                        self.modelIds[bedrockModel] = summary.modelId!
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func summarize(text: String) async throws -> AsyncThrowingStream<BedrockRuntimeClientTypes.ResponseStream, Swift.Error> {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let encodedParams = try! encoder.encode(ModelParams(anthropicVersion: "bedrock-2023-05-31", messages: [
            .init(role: "user", content: [.init(type: "text", text: text)])
        ], maxTokens: 4096, system: nil, temperature: 0.7, topP: 0.9, topK: nil, stopSequences: nil))
        
        let modelId = self.modelIds[.claudeHaikuV3]
        
        let requestStream = InvokeModelWithResponseStreamInput(body: encodedParams, contentType: "application/json", modelId: modelId)
                
        if let requestJson = String(data: encodedParams, encoding: .utf8) {
            print("Request: \(requestJson)")
        }

        let output = try await self.runtimeClient.invokeModelWithResponseStream(input: requestStream)
        return output.body ?? AsyncThrowingStream { _ in }
    }
    
    struct ModelParams: Codable {
        let anthropicVersion: String
        let messages: [Message]
        let maxTokens: Int
        let system: String?
        let temperature: Double?
        let topP: Double?
        let topK: Double?
        let stopSequences: [String]?
        
        struct Message: Codable {
            let role: String
            let content: [MessageContent]
            
            struct MessageContent: Codable {
                let type: String
                let text: String
            }
        }
    }
}
