#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f haxe-ga.zip
zip -r haxe-ga haxelib.json include.xml googleAnalytics
