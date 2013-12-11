#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove haxe-ga
haxelib local haxe-ga.zip
