cmake_minimum_required(VERSION 3.21)
project(my_app CXX)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_STANDARD 17)

add_subdirectory(proto)


# Find installed SDK (point CMAKE_PREFIX_PATH to your install dir)
#find_package(Protobuf CONFIG REQUIRED)
#find_package(gRPC CONFIG REQUIRED)

# --- Proto locations ---
#set(PROTO_DIR ${CMAKE_CURRENT_SOURCE_DIR}/proto)
#set(PROTO_FILE ${PROTO_DIR}/hello.proto)

# Generated files go under proto/generated (inside your source tree)
#set(GEN_DIR ${PROTO_DIR}/generated)
#file(MAKE_DIRECTORY ${GEN_DIR})

# Find tools (from your install/bin)
#find_program(PROTOC_EXECUTABLE protoc HINTS "${CMAKE_PREFIX_PATH}/bin")
#find_program(GRPC_CPP_PLUGIN grpc_cpp_plugin HINTS "${CMAKE_PREFIX_PATH}/bin")
#get_target_property(GRPC_CPP_PLUGIN gRPC::grpc_cpp_plugin LOCATION)

# --- Codegen rules ---
#add_custom_command(
#  OUTPUT ${GEN_DIR}/hello.pb.cc ${GEN_DIR}/hello.pb.h
#  COMMAND ${PROTOC_EXECUTABLE}
#    --proto_path=${PROTO_DIR}
#    --cpp_out=${GEN_DIR}
#    ${PROTO_FILE}
#  DEPENDS ${PROTO_FILE}
#  COMMENT "Generating C++ protobuf sources"
#)

#add_custom_command(
#  OUTPUT ${GEN_DIR}/hello.grpc.pb.cc ${GEN_DIR}/hello.grpc.pb.h
#  COMMAND ${PROTOC_EXECUTABLE}
#    --proto_path=${PROTO_DIR}
#    --grpc_out=${GEN_DIR}
#    --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN}
#    ${PROTO_FILE}
#  DEPENDS ${PROTO_FILE}
#  COMMENT "Generating gRPC C++ sources"
#)

# Group outputs; mark as GENERATED so VS shows them but doesn't expect them to pre-exist
#set(PROTO_SRCS ${GEN_DIR}/hello.pb.cc ${GEN_DIR}/hello.grpc.pb.cc)
#set(PROTO_HDRS ${GEN_DIR}/hello.pb.h  ${GEN_DIR}/hello.grpc.pb.h)
#set_source_files_properties(${PROTO_SRCS} ${PROTO_HDRS} PROPERTIES GENERATED TRUE)

# Optional: create a visible target so the files show up in VS Solution Explorer
#add_custom_target(proto_gen_files ALL DEPENDS ${PROTO_SRCS} ${PROTO_HDRS})
#source_group("proto\\generated" FILES ${PROTO_SRCS} ${PROTO_HDRS})

# Library for generated code
#add_library(proto_objs ${PROTO_SRCS} ${PROTO_HDRS})
#target_include_directories(proto_objs PUBLIC ${GEN_DIR})
#target_link_libraries(proto_objs PUBLIC gRPC::grpc++ protobuf::libprotobuf)

# Your app
add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE myproto)
