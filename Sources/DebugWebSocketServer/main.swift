//
//  MyWebSocketService.swift
//  DebugWebSocketServer
//
//  Created by David Jones on 07/03/2019.
//

import Kitura
import Dispatch
import LoggerAPI
import HeliumLogger
import KituraWebSocket
import MyWebSocketService

Log.logger = HeliumLogger(.info)

let router = Router()

var dataCount: Int = 0
var requestCount: Int = 0
let countQueue = DispatchQueue(label: "CountQueue")

let webSocketService = MyWebSocketService()

let webSocketPath = "/ws"   // Path for WebSocket server
let postPath = "/post"      // Path for POST requests
let statsPath = "/stats"    // Path for stats requests (GET)
let resetPath = "/reset"    // Path for resetting stats (GET)

/// POST route accepting arbitrary data payload (application/raw)
/// Request count and data total are updated.
router.all(postPath, middleware: BodyParser())
router.post(postPath) { (request, response, next) in
    guard let body = request.body, let data = body.asRaw else {
        return try response.status(.badRequest).send("No data sent in request").end()
    }
    countQueue.async {
        dataCount += data.count
        requestCount += 1
        do {
            try response.status(.OK).end()
        } catch {
            next()
        }
    }
}

/// GET route for retreiving stats on request count and total data received.
router.get(statsPath) { (request, response, next) in
    countQueue.async {
        do {
            try response.send("Requests: \(requestCount), data: \(dataCount)\nWebSocket requests: \(webSocketService.requestCount), data: \(webSocketService.dataCount), connections: \(webSocketService.connections.count)\n").end()
        } catch {
            next()
        }
    }
}

/// GET route for resetting stats on request count and total data received.
router.get(resetPath) { (request, response, next) in
    webSocketService.requestCount = 0
    webSocketService.dataCount = 0
    countQueue.async {
        dataCount = 0
        requestCount = 0
        do {
            try response.send("Requests: \(requestCount), data: \(dataCount)\nWebSocket requests: \(webSocketService.requestCount), data: \(webSocketService.dataCount), connections: \(webSocketService.connections.count)\n").end()
        } catch {
            next()
        }
    }
}

// Register WebSocket service on /ws
WebSocket.register(service: webSocketService, onPath: webSocketPath)
print("WebSocket service registered on path: \(webSocketPath)")
// Start Kitura HTTP server
Kitura.addHTTPServer(onPort: 8080, with: router)
print("POST data with Content-Type: application/raw to: \(postPath)")
print("Access stats on \(statsPath), reset stats with \(resetPath)")
Kitura.run()
