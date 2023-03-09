#!/bin/bash

## build folder
rm -rf build
mkdir build

## build dart
echo "1. Pub get..."
dart pub get >/dev/null
echo "2. Run ffigen..."
dart run ffigen >/dev/null
echo "3. Build runner..."
dart run build_runner build >/dev/null
echo "4. Build exe..."
dart compile exe example/dart_odbc_example.dart -o build/example >/dev/null

## run example app
echo "5. Start app..."
echo "----------------------------------- start"
./build/example
echo "----------------------------------- end"