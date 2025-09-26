@echo off
setlocal enabledelayedexpansion
set BRANCH=v1.74.0
set ROOT=C:\CodeProjects\grpc_toolchain_setup\test_grpc_clone_toolchain
set REPO=%ROOT%\grpc
set INSTALL_REL=%ROOT%\install\grpc-1.74-static-release
set INSTALL_DBG=%ROOT%\install\grpc-1.74-static-debug

where cmake >nul 2>nul || (echo CMake not found on PATH & exit /b 1)

if not exist "%ROOT%" mkdir "%ROOT%"
if exist "%REPO%" rmdir /s /q "%REPO%"

echo === Clone gRPC %BRANCH% ===
git clone --recurse-submodules --branch %BRANCH% https://github.com/grpc/grpc "%REPO%" || exit /b 1
cd /d "%REPO%"
git submodule update --init --recursive || exit /b 1

rem --- Build Release (static libs, static CRT) into its own prefix
if exist "_build_release" rmdir /s /q "_build_release"
cmake -S . -B _build_release ^
  -G "Visual Studio 17 2022" -A x64 -T v143 ^
  -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF ^
  -DgRPC_BUILD_SHARED_LIBS=OFF ^
  -Dprotobuf_BUILD_SHARED_LIBS=OFF ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DABSL_MSVC_STATIC_RUNTIME=ON ^
  -DgRPC_MSVC_STATIC_RUNTIME=ON ^
  -Dprotobuf_MSVC_STATIC_RUNTIME=ON ^
  -DCMAKE_CXX_STANDARD=17 -DABSL_PROPAGATE_CXX_STD=ON ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_REL%" || exit /b 1

cmake --build _build_release --config Release --target install || exit /b 1

rem --- Build Debug (static libs, static CRT) into its own prefix
if exist "_build_debug" rmdir /s /q "_build_debug"
cmake -S . -B _build_debug ^
  -G "Visual Studio 17 2022" -A x64 -T v143 ^
  -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF ^
  -DgRPC_BUILD_SHARED_LIBS=OFF ^
  -Dprotobuf_BUILD_SHARED_LIBS=OFF ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DABSL_MSVC_STATIC_RUNTIME=ON ^
  -DgRPC_MSVC_STATIC_RUNTIME=ON ^
  -Dprotobuf_MSVC_STATIC_RUNTIME=ON ^
  -DCMAKE_CXX_STANDARD=17 -DABSL_PROPAGATE_CXX_STD=ON ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreadedDebug" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_DBG%" || exit /b 1

cmake --build _build_debug --config Debug --target install || exit /b 1

echo.
echo Installed Release to: %INSTALL_REL%
echo Installed Debug   to: %INSTALL_DBG%
echo Check: include\, lib\ (*.lib), bin\protoc.exe, bin\grpc_cpp_plugin.exe
