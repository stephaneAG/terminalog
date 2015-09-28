#!/bin/bash

# serverService
#
#
fifoName="servicePipe";
[ -p $fifoName ] || mkfifo $fifoName;
#  trap Ctrl-C to delete fifo
trap ctrl_c INT
function ctrl_c() {
  #echo "** Trapped CTRL-C"
  # don't know why it printed 'rm: cannot remove ‘servicePipe’: No such file or directory', but now it's quit ;D
  rm "$fifoName" 2> /dev/null
  exit 0
}
#
# [old] usage:
# while true; do nc -l 3333 < servicePipe | head -1 | ./serverService.sh 1> servicePipe; done
#
# [new] usage:
# ./serverService.sh
#

# check the presence of arguments passed to the script, in which case we do the 'while read' stuff
# else, we just use the 'while true' stuff to start the server
if [ ! $# -eq 0 ]
then
  #echo "arguments supplied" > /dev/tty


  # output to the server terminal
  #echo "server started !" > /dev/tty

  # get stuff from stdin - tied to netcat's output
  while read -a request
  do

    # output to the server terminal, neverminding the piped output
    #echo -e "request received! :\n${request[@]}" > /dev/tty
  
    # parse the request
    #if [[ "${request[0]}" == "GET" ]]; then echo "-> GET REQUEST" >/dev/tty; fi
    #if [[ "${request[0]}" == "POST" ]]; then echo "-> POST REQUEST" >/dev/tty; fi

    # LOG DATA TO SERVER TERMINAL
    echo -e "DATA FROM CLIENT:" > /dev/tty
    echo ${request[1]:14} | base64 -d > /dev/tty
    echo -e "\n"> /dev/tty

    # TODO: parse the content of the data
    # tmp
    name=`echo ${request[1]:14} | base64 -d`
    dudeName="$name"
    ladyName="$name"

    # TODO:LOG DATA TO SERVER TERMINAL
    # log the dude name
    # log the lady name 

    # format our response data
    b64data="$(echo 'DATA FROM SERVER: \n'\
                    'Hello World from the localServer [Bash] !'\
                    '%s[color: #FE524C]INFOS:%s[color: #050504] from the localServer =>' "${dudeName}" 'welcomed' "$ladyName" '[Bash]'\
            | base64)"

    # return stuff to client
    cat<<-EOF
	HTTP/1.1 200 OK
	Access-Control-Allow-Origin: *
	Content-type: text/plain

	$b64data
	EOF
  
    # exit early - aka do not hang ( ex: when curl-ing stuff ) - /!\ discard lines after the first one even when not using | head -1
    #exit 0

  done

else
  #echo 'ARGUMENTS NOT PROVIDED ! => launching server ;D !!' > /dev/tty
  # the following should ? work, & allow us to use a nice ./<executable_name> instead of .. the following ;)
  while true; do nc -l 3000 < servicePipe | head -1 | ./localServer2.sh placeholderArg 1> servicePipe; done
fi

exit 0
