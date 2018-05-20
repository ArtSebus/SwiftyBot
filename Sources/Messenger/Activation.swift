//
//  Activation.swift
//  SwiftyBot
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 - 2018 Fabrizio Brancati.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import Vapor

public struct Activation: Codable {
    private(set) public var mode: String
    private(set) public var token: String
    private(set) public var challenge: String

    /// Coding keys, used by Codable protocol.
    private enum CodingKeys: String, CodingKey {
        case mode = "hub.mode"
        case token = "hub.verify_token"
        case challenge = "hub.challenge"
    }
    
    public static func check(_ request: Request) throws -> HTTPResponse {
        /// Try decoding the request query as `Activation`.
        let activation = try request.query.decode(Activation.self)
        
        guard messengerSecret != "" && messengerToken != "" else {
            /// Show errors in console.
            let terminal = Terminal()
            terminal.error("Missing secret or token keys!", newLine: true)
            throw Abort(.badRequest, reason: "Missing Messenger verification data.")
        }
        
        /// Check for "hub.mode", "hub.verify_token" & "hub.challenge" query parameters.
        guard activation.mode == "subscribe", activation.token == messengerSecret else {
            throw Abort(.badRequest, reason: "Missing Messenger verification data.")
        }
        
        /// Create a response with the challenge query parameter to verify the webhook.
        let body = try HTTPBody(data: JSONEncoder().encode(activation.challenge))
        /// Send a 200 (OK) response.
        return HTTPResponse(status: .ok, headers: ["Content-Type": "text/plain"], body: body)
    }
}