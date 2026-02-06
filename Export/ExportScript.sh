#!/bin/bash

cd /home/logan/Documents/Godot\ Projects/HyperTag/Export

rm -rf ./FinalFiles/*

zip -r ./FinalFiles/Web.zip ./WebBuild/
zip -r ./FinalFiles/Windows.zip ./WindowsBuild/
zip -r ./FinalFiles/Linux.zip ./WindowsBuild/

rm -rf ./WebBuild/*
rm -rf ./WindowsBuild/*
rm -rf ./LinuxBuild/*

mv ./Source/* ./FinalFiles/Source.zip

echo done
