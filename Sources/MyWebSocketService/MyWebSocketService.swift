//
//  MyWebSocketService.swift
//  DebugWebSocketServer
//
//  Created by David Jones on 07/03/2019.
//

import Foundation
import Dispatch
import LoggerAPI
import KituraWebSocket

extension WebSocketConnection: Hashable {
    public static func == (lhs: WebSocketConnection, rhs: WebSocketConnection) -> Bool {
        return lhs.id == rhs.id
    }
    public var hashValue: Int {
        return id.hashValue
    }
}

/// Simple WebSocketService that receives and records a count of messages
/// and the cumulative size of the data payloads.
public class MyWebSocketService: WebSocketService {

    private let connectionLock = DispatchQueue(label: "connectionLock", attributes: .concurrent)
    private var _connections = Set<WebSocketConnection>()

    /// The set of connections currently connected to this service.
    public var connections: Set<WebSocketConnection> {
        return connectionLock.sync {
            return _connections
        }
    }

    private func addConnection(newValue: WebSocketConnection) {
        return connectionLock.sync(flags: .barrier) {
            return _connections.insert(newValue)
        }
    }

    private func removeConnection(oldValue: WebSocketConnection) {
        return connectionLock.sync(flags: .barrier) {
            return _connections.remove(oldValue)
        }
    }

    private var _dataCount: Int = 0
    private var _requestCount: Int = 0

    private let countQueue = DispatchQueue(label: "CountQueue", attributes: .concurrent)

    /// The cumulative number of bytes of message payload received.
    public var dataCount: Int {
        get {
            return countQueue.sync {
                return _dataCount
            }
        }
        set {
            return countQueue.sync(flags: .barrier) {
                _dataCount = newValue
            }
        }
    }

    /// The number of messages received.
    public var requestCount: Int {
        get {
            return countQueue.sync {
                return _requestCount
            }
        }
        set {
            return countQueue.sync(flags: .barrier) {
                _requestCount = newValue
            }
        }
    }

    public init() {}

    public func connected(connection: WebSocketConnection) {
        Log.info("WS Client connected: \(connection.id)")
        addConnection(newValue: connection)
    }

    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        Log.info("WS Client disconnected: \(connection.id), reason: \(reason)")
        removeConnection(oldValue: connection)
    }

    public func received(message: Data, from: WebSocketConnection) {
        requestCount += 1
        dataCount += message.count
    }

    public func received(message: String, from: WebSocketConnection) {
        requestCount += 1
        dataCount += message.utf8.count
    }


}
