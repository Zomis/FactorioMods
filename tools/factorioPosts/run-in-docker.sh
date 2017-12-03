#!/bin/bash

docker run --rm -v "$PWD":/home/groovy/scripts -w /home/groovy/scripts groovy groovy factorioPosts.groovy
