//
//  BedrockClient.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-30.
//

import AWSBedrock
import AWSBedrockRuntime
import AWSClientRuntime

import Foundation

// MARK: enums
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

// MARK: constants
let contentType = "application/json"
let anthropicVersion = "bedrock-2023-05-31"
let genAIModelToBedrock: [GenAIModel: AWSBedrockModel] = [
    .fast: .claudeHaikuV3,
    .smart: .claudeOpusV3,
]

// MARK: client
class AWSClient: GenAIClient {
    
    private let client: BedrockClient
    private let runtimeClient: BedrockRuntimeClient

    private let encoder: JSONEncoder
    
    private(set) var modelIds: [AWSBedrockModel: String]

    required init?() {
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

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase

        self.modelIds = [:]
    }

    func initModels() async throws(GenAIClientError) {
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
        } catch let error as AWSServiceError {
            switch error.errorCode {
            case .some("ExpiredTokenException"): throw .expiredToken
            default: throw .genericError(error.message ?? "Error AWS Client")
            }
        } catch {
            throw .genericError(error.localizedDescription)
        }
    }

    func input(text: String, model: GenAIModel) -> AsyncThrowingStream<GenAIResponse, Error> {
        let encodedParams = try! encoder.encode(ModelParams(anthropicVersion: anthropicVersion, messages: [
            .init(role: "user", content: [.init(type: "text", text: text)])
        ], maxTokens: 4096, system: nil, temperature: 0.7, topP: 0.9, topK: nil, stopSequences: nil))

        guard let bedrockModel = genAIModelToBedrock[model] else {
            return AsyncThrowingStream { continuation in
                Task {
                    continuation.finish(throwing: GenAIClientError.genericError("No Bedrock model found for GenAI model \(model)"))
                }
            }
        }

        let modelId = self.modelIds[bedrockModel]
        let requestStream = InvokeModelWithResponseStreamInput(body: encodedParams, contentType: contentType, modelId: modelId)

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let stream = try await self.runtimeClient.invokeModelWithResponseStream(input: requestStream)
                    for try await event in stream.body! {
                        continuation.yield(try convertStreamResponse(event))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
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
    
    private func convertStreamResponse(_ response: BedrockRuntimeClientTypes.ResponseStream) throws -> GenAIResponse {
        switch response {
        case .chunk(let part):
            let jsonObject = try JSONSerialization.jsonObject(with: part.bytes!, options: [])
            if let chunkText = extractTextFromChunk(jsonObject) {
                return .init(text: chunkText)
            }
        case .sdkUnknown(let unknown):
            throw GenAIClientError.genericError(unknown)
        }

        return .init(text: "")
    }
    
    private func extractTextFromChunk(_ jsonObject: Any) -> String? {
        if let dict = jsonObject as? [String: Any], let delta = dict["delta"] as? [String: String], delta["type"] == "text_delta" {
            return delta["text"]
        }
        return nil
    }
}

extension AWSClient: @unchecked Sendable {}
