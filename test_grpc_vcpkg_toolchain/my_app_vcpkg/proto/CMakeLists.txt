find_package(Protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)

message(STATUS "Protobuf imported: $<TARGET_EXISTS:protobuf::libprotobuf>")
message(STATUS "gRPC imported:     $<TARGET_EXISTS:gRPC::grpc++>")
get_target_property(_grpc_plugin gRPC::grpc_cpp_plugin LOCATION)
message(STATUS "gRPC cpp plugin:   ${_grpc_plugin}")


#
# Protobuf/Grpc source files
#
set(PROTO_FILES
    hello.proto
#    myproto/addressbook.proto
)

#
# Add Library target with protobuf sources
#
add_library(myproto ${PROTO_FILES})
target_link_libraries(myproto
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc
        gRPC::grpc++
)

#
# Compile protobuf and grpc files in myproto target to cpp
#
get_target_property(grpc_cpp_plugin_location gRPC::grpc_cpp_plugin LOCATION)

set(PROTO_GEN_DIR ${CMAKE_CURRENT_SOURCE_DIR}/generated)
file(MAKE_DIRECTORY ${PROTO_GEN_DIR})

protobuf_generate(
  TARGET myproto
  LANGUAGE cpp
  OUT_VAR PROTO_SRCS
  PROTOC_OUT_DIR ${PROTO_GEN_DIR}
)

protobuf_generate(
  TARGET myproto
  LANGUAGE grpc
  GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
  PLUGIN "protoc-gen-grpc=${grpc_cpp_plugin_location}"
  OUT_VAR GRPC_SRCS
  PROTOC_OUT_DIR ${PROTO_GEN_DIR}
)

target_include_directories(myproto PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(myproto PUBLIC ${PROTO_GEN_DIR})