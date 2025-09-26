cmake_minimum_required(VERSION 3.21)
project(my_app CXX)
set(CMAKE_CXX_STANDARD 17)

# You already point this at your SDK via CMakePresets:
# CMAKE_PREFIX_PATH = C:/CodeProjects/grpc_toolchain_setup/test_grpc_clone_toolchain/install/grpc-1.74-static

# Find exactly the SDK you installed
find_package(Protobuf CONFIG REQUIRED)   # provides protobuf::libprotobuf (and often protobuf::protoc)
find_package(gRPC CONFIG REQUIRED)       # provides gRPC::grpc++



# Helper to print which runtime_version.h is used and the value it supplies.
file(WRITE ${CMAKE_BINARY_DIR}/check_version.cpp [=[
  #include "google/protobuf/runtime_version.h"
  #define STR_(x) #x
  #define STR(x) STR_(x)
  #pragma message("PROTOBUF_VERSION from header = " STR(PROTOBUF_VERSION))
  int main() {}
]=])

add_executable(check_protobuf_header ${CMAKE_BINARY_DIR}/check_version.cpp)

# Show includes so we can see the exact path to runtime_version.h
#if (MSVC)
#  target_compile_options(check_protobuf_header PRIVATE /showIncludes)
#endif()

# Put the protobuf include BEFORE anything else, explicitly.
get_target_property(_pb_inc protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)
target_include_directories(check_protobuf_header BEFORE PRIVATE "${_pb_inc}")






# Print what we actually found (good for sanity)
message(STATUS "Using Protobuf from: ${Protobuf_DIR}")
message(STATUS "Using gRPC from: ${gRPC_DIR}")

message(STATUS "Protobuf_DIR = ${Protobuf_DIR}")
message(STATUS "gRPC_DIR     = ${gRPC_DIR}")
message(STATUS "Protobuf_VERSION = ${Protobuf_VERSION}")
get_target_property(_pb_includes protobuf::libprotobuf INTERFACE_INCLUDE_DIRECTORIES)
message(STATUS "protobuf::libprotobuf include dirs = ${_pb_includes}")

# --- Proto locations ---
set(PROTO_DIR ${CMAKE_CURRENT_SOURCE_DIR}/proto)
set(PROTO_FILE ${PROTO_DIR}/hello.proto)

# Generated files go under proto/generated (inside your source tree)
set(GEN_DIR ${PROTO_DIR}/generated)
file(MAKE_DIRECTORY ${GEN_DIR})

if (MSVC)
  add_compile_options(/showIncludes)
endif()

# Resolve the exact tools from your install. Use NO_DEFAULT_PATH so PATH is ignored.
# We also REQUIRE them so CMake fails fast if not found in the expected location.
if(WIN32)
  set(_PROTOC_NAME protoc.exe)
  set(_GRPC_PLUGIN_NAME grpc_cpp_plugin.exe)
else()
  set(_PROTOC_NAME protoc)
  set(_GRPC_PLUGIN_NAME grpc_cpp_plugin)
endif()

find_program(PROTOC_EXECUTABLE
  NAMES ${_PROTOC_NAME}
  HINTS "${CMAKE_PREFIX_PATH}/bin"
  NO_DEFAULT_PATH
  REQUIRED
)
find_program(GRPC_CPP_PLUGIN
  NAMES ${_GRPC_PLUGIN_NAME}
  HINTS "${CMAKE_PREFIX_PATH}/bin"
  NO_DEFAULT_PATH
  REQUIRED
)

# Optional: show their absolute paths for debugging
message(STATUS "PROTOC_EXECUTABLE: ${PROTOC_EXECUTABLE}")
message(STATUS "GRPC_CPP_PLUGIN  : ${GRPC_CPP_PLUGIN}")

# --- Codegen rules ---
add_custom_command(
  OUTPUT ${GEN_DIR}/hello.pb.cc ${GEN_DIR}/hello.pb.h
  COMMAND ${PROTOC_EXECUTABLE}
    --proto_path=${PROTO_DIR}
    --cpp_out=${GEN_DIR}
    ${PROTO_FILE}
  DEPENDS ${PROTO_FILE}
  COMMENT "Generating C++ protobuf sources"
  VERBATIM
)

add_custom_command(
  OUTPUT ${GEN_DIR}/hello.grpc.pb.cc ${GEN_DIR}/hello.grpc.pb.h
  COMMAND ${PROTOC_EXECUTABLE}
    --proto_path=${PROTO_DIR}
    --grpc_out=${GEN_DIR}
    --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN}
    ${PROTO_FILE}
  DEPENDS ${PROTO_FILE}
  COMMENT "Generating gRPC C++ sources"
  VERBATIM
)

# Group outputs; mark as GENERATED so VS shows them but doesn't expect them to pre-exist
set(PROTO_SRCS ${GEN_DIR}/hello.pb.cc ${GEN_DIR}/hello.grpc.pb.cc)
set(PROTO_HDRS ${GEN_DIR}/hello.pb.h  ${GEN_DIR}/hello.grpc.pb.h)
set_source_files_properties(${PROTO_SRCS} ${PROTO_HDRS} PROPERTIES GENERATED TRUE)

add_custom_target(proto_gen_files ALL DEPENDS ${PROTO_SRCS} ${PROTO_HDRS})
source_group("proto\\generated" FILES ${PROTO_SRCS} ${PROTO_HDRS})

# Library for generated code
add_library(proto_objs ${PROTO_SRCS} ${PROTO_HDRS})
target_include_directories(proto_objs PUBLIC ${GEN_DIR})
# Link against the EXACT imported targets from your install
target_link_libraries(proto_objs PUBLIC gRPC::grpc++ protobuf::libprotobuf)

# Your app
add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE proto_objs)
