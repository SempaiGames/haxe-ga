#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f haxe-ga.zip
zip -0r haxe-ga haxelib.json googleAnalytics
