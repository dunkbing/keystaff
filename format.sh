#!/bin/bash
find . -name "*.swift" -exec swift-format -i {} \;
