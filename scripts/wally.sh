#!/bin/bash

echo Starting Wally Update
wally install
rojo sourcemap test.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
echo Finishing Wally Update