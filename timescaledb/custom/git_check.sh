#!/bin/sh

GITPATH=$1
UPSTREAM="HEAD"
LOCAL=$(git -C ${GITPATH} rev-parse ${UPSTREAM})
REMOTE=$(git -C ${GITPATH} rev-parse ${UPSTREAM})
BASE=$(git -C ${GITPATH} merge-base HEAD ${UPSTREAM})

if [ $LOCAL = $REMOTE ]; then
	echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
	echo "Need to pull"
	git -C ${GITPATH} pull
elif [ $REMOTE = $BASE ]; then
	echo "Need to push"
else
	echo "Diverged"
fi

# This code was tweaked from the example at 
# https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
