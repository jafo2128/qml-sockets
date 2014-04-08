
import QtTest 1.0
import QtQuick 2.0

import org.jemc.qml.Sockets 1.0

TestCase {
    id: test
    name: "TCPSocket#match"
    
    TCPServer {
        id: server
        port: 4998
        
        property string welcome
        property string welcome2
        
        function reset() { welcome  = ""; welcome2 = "" }
        Component.onCompleted: reset()
        
        onClientConnected: {
            client.write(welcome)
            test.wait(15) // Space between messages to separate as packets
            client.write(welcome2)
            client.disconnect()
        }
    }
    
    TCPSocket {
        id: socket
        host: "127.0.0.1"
        port: 4998
        
        property var matches
        
        function reset() { matches = [] }
        Component.onCompleted: reset()
        
        onMatch: matches.push(matchString)
        
        onConnected: {
            test.compare(socket.matchBuffer, "", "matchBuffer reset on connect")
        }
    }
    
    function initTestCase() { server.listen() }
    
    function wait_for_connect()    { while(socket.state!==2) { wait(0) } }
    function wait_for_disconnect() { while(socket.state!==0) { wait(0) } }
    
    function test_default_expression() {
        compare(socket.expression,
                /(.*?)[\r\n]+/)
    }
    
    function test_match() {
        socket.reset()
        server.reset()
        
        socket.expression = /(.*?)[\r\n]+/
        
        var welcome = ["Welcome\n","the\r","new\n\r","client\r\n"]
        var the_rest = "the_rest"
        server.welcome = welcome.join('')+the_rest
        
        socket.connect()
        wait_for_disconnect()
        
        compare(socket.matches, welcome)
        compare(socket.matchBuffer, the_rest)
    }
}