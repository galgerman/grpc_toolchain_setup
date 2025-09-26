#!/usr/bin/env bash
set -euo pipefail

BRANCH="v1.74.0"
ROOT="$HOME/code/test_grpc_toolchain"
REPO="$ROOT/grpc"
INSTALL_REL="$ROOT/install/grpc-1.74-static-release"
INSTALL_DBG="$ROOT/install/grpc-1.74-static-debug"

# Make root folder
mkdir -p "$ROOT"

# Clean repo if exists
rm -rf "$REPO"

echo "=== Clone gRPC $BRANCH ==="
git clone --recurse-submodules --branch "$BRANCH" https://github.com/grpc/grpc "$REPO"
cd "$REPO"
git submodule update --init --recursive

# --- Build Release ---
rm -rf _build_release
cmake -S . -B _build_release \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF \
  -DgRPC_BUILD_SHARED_LIBS=OFF \
  -Dprotobuf_BUILD_SHARED_LIBS=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_CXX_STANDARD=17 -DABSL_PROPAGATE_CXX_STD=ON \
  -DCMAKE_CXX_FLAGS="-static-libgcc -static-libstdc++" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_REL"

cmake --build _build_release --target install

# --- Build Debug ---
rm -rf _build_debug
cmake -S . -B _build_debug \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF \
  -DgRPC_BUILD_SHARED_LIBS=OFF \
  -Dprotobuf_BUILD_SHARED_LIBS=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_CXX_STANDARD=17 -DABSL_PROPAGATE_CXX_STD=ON \
  -DCMAKE_CXX_FLAGS="-g -O0 -static-libgcc -static-libstdc++" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DBG"

cmake --build _build_debug --target install

echo
echo "Installed Release to: $INSTALL_REL"
echo "Installed Debug   to: $INSTALL_DBG"
echo "Check: include/, lib/ (*.a), bin/protoc, bin/grpc_cpp_plugin"
