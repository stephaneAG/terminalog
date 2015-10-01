#!/bin/bash

# test2 - getting stuff from stdin to a buffer, & then output it & its number of lines
#
# differs from test1.sh as it doesn't uses -t parameter in read but insted a "quick timestamp hack" to stop filling the buffer with input(s)
#
# this test can be either called as: 
# './test1.sh' 
# -> in this case, we have -t <x> seconds to enter input from stdin,
#    or we can also manually chose to end input by using Ctrl-D
#    ( The ^D char (aka \04 or 0x4) is the default value for the eof )
#
# 'cat dummyGET.txt | ./test1.sh'
# -> in this case, piping a file to it 'll instantly trigger an EOF,
#    & thus display the output imediately
#
# WHERE IT GETS INTERESTING:
#
# './dummyCounter.sh 10 0.5 | ./test1.sh'
# -> in this case, the script waits for the entire stuff from stdin to be received,
#    as each new write is added 0.5 seconds after the previous one
#
# './dummyCounter.sh 10 1 | ./test1.sh'
# -> in this case, the script DOESN'T wait for the entire stuff from stdin to be received,
#    but instead discard any output received after one second of inactivity of stdin
#
#  TODO: use a fifo & check how it behaves
# R: to quickly encode a CLEAN ( without new lines in it) base64 txt:
#    cat test1.sh | base64 -w 0; echo
#
# R: for correctly formatted POST requests, the 'Content-Length' property gives use the size of the data
#
# == kinda interesting :D ==
#
# echo -e "hello world\nTEF\nscrewed me up!" | { read test; echo "test=$test"; }
#
# echo -e "hello world\nTEF\nscrewed me up!" | { contentRead=$(while read -t 1 line; do echo "$line"; done); echo "$contentRead"; }
#
# SO WHAT ABOUT:
#  ... nc < servicePipe | { contentRead=$(while read -t 1 line; do echo "$line"; done); echo "$contentRead"; ... } > servicePipe
#  |_|                                                                                                       |_|
#   |                                                                                                         |
# <start of nc loop>                                                                         < some fcn outputting dynamic stuff>

# R: by using the following call, we can verify that the timeout has been respected ( kinda "crude preview" ;p )
#    time ./dummyCounter.sh 10 0.5 | ./test2.sh 3

getTimestamp(){ date +"%s"; }
#getTimestamp(){ date +"%H%M%S"; }
#callTime=$(date +"%H%M%S")
callTime=$(getTimestamp)
#timeout=1
timeout=$1
contentRead=$(
  while read line
  do
    #if [ ! "$callTime" -lt $(( $(date +"%H%M%S") + "$timeout" )) ] break; fi  # Right idea, but wrong order ( I'm tired ;p ) nb: useful to know: valid syntax ;D
    #if [ ! $(date +"%H%M%S") -lt $(( $callTime + $timeout )) ]; then break; fi
    if [ ! $(getTimestamp) -lt $(( $callTime + $timeout )) ]; then break; fi
    echo "$line"
  done
)
echo 'read ended'

echo '=== content ==='
echo -n 'number of lines:'
echo "$contentRead" | wc -l
echo '=== BUFFER START ==='
echo -e "$contentRead"
echo '==== BUFFER END ===='


# GET / POST & content fetching
method="${contentRead:0:4}"
if [[ "$method" == "GET " ]]; then
  echo "METHOD: GET";
  firstLine="${contentRead%%$'\n*'}"
  data=$(echo "${firstLine:18:-9}" | base64 -d)
elif [[ "$method" == "POST" ]]; then
  echo "METHOD: POST";
  data=$(echo "${contentRead##$'*\n'}" | base64 -d)
else echo "UNKNOWN METHOD: $method";
fi

echo '=== DATA START ==='
echo "$data"
echo '==== DATA END ===='

exit 0
