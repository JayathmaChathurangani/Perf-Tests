// A system package containing protocol access constructs
// Package objects referenced with 'http:' in code
import ballerina/http;
import ballerina/io;
import ballerina/log;

// A service endpoint represents a listener
endpoint http:Listener listener {
    port:8080
};

// A service is a network-accessible API
// Advertised on '/hello', port comes from listener endpoint
service<http:Service> hello bind listener {

    // A resource is an invokable API method
    // Accessible at '/hello/sayHello
    // 'caller' is the client invoking this resource
    sayHello (endpoint caller, http:Request request) {
        http:Response response = new;
        response.setPayload("Hello Ballerina!");

        io:println("Hello Service Invoked");
        caller->respond(response) but { error e => log:printError(
                                                  "Error sending response", err = e) };
    }
}