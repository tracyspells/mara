#!/bin/bash

echo Starting Wally Update
wally install
rojo sourcemap default.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
echo Finishing Wally Update