//
//  GenAIClient.swift
//  TextSniper
//
//  Created by Lofrumento, Gianluca on 2024-09-30.
//

import Foundation

actor GenAIClient {
    
    let client: AWSClient

    init?() async throws {
        guard let client = AWSClient() else {
            return nil
        }
        
        self.client = client
        
        await self.client.initModels()
    }

}
