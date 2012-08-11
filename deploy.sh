#!/bin/bash

status=$(git status | head -n 1)
if [[ "$status" != "# On branch master" ]]; then
    echo "Not on master branch. Goodbye"
    exit 1
fi

status=$(git status | tail -n -1)
if [[ "$status" != "nothing to commit (working directory clean)" ]]; then
    echo "There are pending changes. Goodbye"
    exit 1
fi

version=$(python -c "import prawtools; print prawtools.__version__")

read -p "Do you want to deploy $version? [y/n] " input
case $input in
    [Yy]* ) ;;
    * ) echo "Goodbye"; exit 1;;
esac

python setup.py sdist upload -s
if [ $? -ne 0 ]; then
    echo "Pushing distribution failed. Aborting."
    exit 1
fi

git tag -s "prawtools-$version" -m "prawtools-$version"
if [ $? -ne 0 ]; then
    echo "Tagging version failed. Aborting."
    exit 1
fi

git push origin master --tags
