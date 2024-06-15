#!/bin/bash

echo Starting Wally Update
wally install
rojo sourcemap default.project.json --output sourcemap.json
echo Finishing Wally Update