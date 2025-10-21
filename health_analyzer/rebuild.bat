@echo off
echo ===================================
echo Rebuilding LabLens App
echo ===================================
echo.

echo Step 1: Cleaning build...
call flutter clean
echo.

echo Step 2: Getting dependencies...
call flutter pub get
echo.

echo Step 3: Building and running app...
echo NOTE: Make sure to STOP the current running app first!
echo.
pause

call flutter run

echo.
echo ===================================
echo Build Complete!
echo ===================================
pause
