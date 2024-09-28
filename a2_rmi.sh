#!/bin/sh

docker images \
	| grep "863419159770.dkr.ecr.eu-north-1.amazonaws.com" \
	| sed 's/\s\s*/ /g' \
	| cut -d " " -f3 \
	| xargs -I {} sh -c 'echo "Removing docker image: {}"; docker rmi {}'


