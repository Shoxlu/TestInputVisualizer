@echo off
REM Build the executable

REM Build the DLL
i686-w64-mingw32-gcc -Wl,--kill-at -shared -I "src/include" -o  ..\..\thcrap\bin\InputVisualizer.dll src/*.cpp src/squirrel/*.cpp -std=c++20 -lstdc++ -ldbghelp -lws2_32 -Wno-narrowing 

IF ERRORLEVEL 1 (
    echo Failed to build InputVisualizer.dll
    exit /b 1
)

echo Build completed successfully.