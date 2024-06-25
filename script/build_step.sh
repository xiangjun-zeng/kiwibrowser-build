#!/bin/sh
task=$1
if test ! -n "$task"
then
    echo 'usage: build_step.sh <task_name>'
    exit 1
fi
test -f "$FLAG_STOP" && echo skip $task && exit 0 || echo ninja $task
cd "$ROOT/src"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
echo "export JAVA_HOME=$JAVA_HOME" >> $GITHUB_ENV
ninja -C out/arm64/ $task || ( test $? == 143 && echo ninja canceld )
if test -n "$PUSH_TOKEN"
then
    cd "$HOME/cache"
    git add .
    git commit -m "ninja $task" || echo no change,
    git push
fi
