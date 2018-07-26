import ballerina/http;
import ballerina/log;

// By default, Ballerina assumes that the service is to be exposed via HTTP/1.1.
service<http:Service> hello bind { port: 8080 } {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/payloadCheck"
    }
    sayHellow(endpoint caller, http:Request req) {
        string textValue = check req.getTextPayload();
        http:Response res = new;
        res.setTextPayload(textValue);
        caller->respond(res) but {
            error err => log:printError(err.message, err = err)
        };
    }
}
