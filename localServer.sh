#!/bin/bash

# local server using Bash
# -----------------------------------------------------------------------------
# R: working one-liner:
# while true; do echo -e "HTTP/1.1 200 OK\n\n $(date) $(echo "Hello Tef from Bash" | base64)" | nc -l -p 3000 | head -1 | while read -a lines; do echo ${lines[1]:14} | base64 -d; echo; done; done;
# R: other way of splitting just to check out if it was valid ;)
# echo -e "HTTP/1.1 200 OK\n\n $(date) $(echo "Hello Tef from Bash" | base64)" | \
#   nc -l -p 3000 | head -1 | while read -a lines;
# -----------------------------------------------------------------------------
# --
# R: temporarly hardcoded, 'til I figure out a way to cat a fifo to nc listen before parsing the reuest, so as to be able to write to it after the actual parsing
dudeName="HardTef"
ladyName="HardJulie"
## "%s[color: #FE524C]INFOS:%s[color: #050504] from the localServer => $dudeName welcomed $ladyName [Bash]"\
# --
while true
do
  # RETURN DATA TO CLIENT
  #echo -e "HTTP/1.1 200 OK\nContent-type: text/html\n\n$(echo 'Hello Tef from Bash' | base64)" \
  echo -e "HTTP/1.1 200 OK\n"\
"Content-type: text/html\n\n"\
"$(echo 'DATA FROM SERVER: \n'\
        'Hello World from the localServer [Bash] !'\
        '%s[color: #FE524C]INFOS:%s[color: #050504] from the localServer =>' "${dudeName}" 'welcomed' "$ladyName" '[Bash]'\
  | base64)" \
      | nc -l -p 3000 \
        | head -1 \
          | while read -a lines
            #echo -e "HTTP/1.1 200 OK\n\n $(date) $(echo "Hello Tef from Bash" | base64)" | nc -l -p 3000 | head -1 | while read -a lines;
            do
              # LOG DATA TO SERVER TERMINAL
              echo -e "\n\nDATA FROM CLIENT: \n"
              echo ${lines[1]:14} | base64 -d;
              # TODO: parse the dude & lady names & display that as client infos
              echo;
            done;
done;
