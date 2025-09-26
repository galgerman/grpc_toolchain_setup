#include <grpcpp/grpcpp.h>
#include "hello.grpc.pb.h"
#include <iostream>

int main() {
    // Normally you'd spin up a server or make a client call.
    // Here we just prove the generated code + headers link OK.
    hello::HelloRequest req;
    req.set_name("World");

    hello::HelloReply rep;
    rep.set_message("Hello " + req.name());

    std::cout << rep.message() << std::endl;
    return 0;
}
