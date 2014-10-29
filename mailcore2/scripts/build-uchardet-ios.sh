#!/bin/sh

pushd "`dirname "$0"`" > /dev/null
scriptpath="`pwd`"
popd > /dev/null

. "$scriptpath/include.sh/build-dep.sh"

url="https://github.com/dinhviethoa/uchardet"
rev=56b8581a701c3c51d489ab2f21124da8a1f2c77b
name="uchardet-ios"
xcode_target="uchardet-ios"
xcode_project="uchardet.xcodeproj"
library="libuchardet-ios.a"
embedded_deps=""

build_git_ios
