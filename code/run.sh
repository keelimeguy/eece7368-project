#!/bin/bash

## Compile and run the SpecC tests
make || exit 1
make test
