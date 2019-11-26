#!/bin/sh

GITPATH=$1
UPSTREAM="HEAD"
LOCAL=$(git -C ${GITPATH} rev-parse HEAD)
REMOTE=$(git -C ${GITPATH} rev-parse ${UPSTREAM})
BASE=$(git -C ${GITPATH} merge-base HEAD ${UPSTREAM})

if [ $LOCAL = $REMOTE ]; then
    # echo 0
	echo "Up-to-date"
elif [ $LOCAL = $BASE ]; then
    # echo 1
	echo "Need to pull"
	git -C ${GITPATH} pull
elif [ $REMOTE = $BASE ]; then
    # echo 2
	echo "Need to push"
else
    # echo 3
	echo "Diverged"
fi

# echo $? for return code
# Example from https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
