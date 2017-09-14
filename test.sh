#!/bin/bash

echo "start"

path="testDir2"
echo "path $path"

for file in $path/*; do
	echo "file $file"
done

echo "end"
