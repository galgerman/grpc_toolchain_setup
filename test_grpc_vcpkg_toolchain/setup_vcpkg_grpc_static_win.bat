@echo off
setlocal enabledelayedexpansion

set ROOT=C:\CodeProjects\grpc_toolchain_setup\test_grpc_vcpkg_toolchain
set VCPKG=%ROOT%\vcpkg
set TARGET_TRIPLET=x64-windows-static
set HOST_TRIPLET=x64-windows
set PACKAGES_TARGET=protobuf:%TARGET_TRIPLET% grpc:%TARGET_TRIPLET%
set PACKAGES_HOST=protobuf:%HOST_TRIPLET% grpc:%HOST_TRIPLET%

where git >nul 2>nul || (echo [ERROR] git not found on PATH & exit /b 1)

if not exist "%ROOT%" mkdir "%ROOT%"
if not exist "%VCPKG%\.git" (
  echo [INFO] Cloning vcpkg ...
  git clone https://github.com/microsoft/vcpkg "%VCPKG%" || exit /b 1
) else (
  echo [INFO] vcpkg already exists
)

pushd "%VCPKG%"
call .\bootstrap-vcpkg.bat || exit /b 1

echo [INFO] Installing target triplet: %PACKAGES_TARGET% ...
.\vcpkg.exe install %PACKAGES_TARGET% || exit /b 1

echo [INFO] Installing host triplet (tools): %PACKAGES_HOST% ...
.\vcpkg.exe install %PACKAGES_HOST% || exit /b 1

REM echo [INFO] Enabling CMake integration ...
REM .\vcpkg.exe integrate install

echo [INFO] Installed versions:
.\vcpkg.exe list grpc
.\vcpkg.exe list protobuf

echo [INFO] Expect these files to exist:
echo   %VCPKG%\installed\%TARGET_TRIPLET%\share\grpc\gRPCConfig.cmake
echo   %VCPKG%\installed\%TARGET_TRIPLET%\share\protobuf\protobuf-config.cmake
echo   %VCPKG%\installed\%HOST_TRIPLET%\tools\protobuf\protoc.exe
echo   %VCPKG%\installed\%HOST_TRIPLET%\tools\grpc\grpc_cpp_plugin.exe

popd
echo [OK] Done.
endlocal
