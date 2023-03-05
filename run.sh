#!/bin/bash

## build c lib
echo "1. Build lib..."
rm -rf build
mkdir build
cd build || exit
cmake ../c_lib >/dev/null
make >/dev/null

## build dart
echo "2. Build app..."
cd ../
# dart pub get >/dev/null
dart run ffigen >/dev/null
dart compile exe example/dart_odbc_example.dart -o build/example >/dev/null

## run example app
echo "3. Start app..."
echo "----------------------------------- start"
./build/example
echo "----------------------------------- end"