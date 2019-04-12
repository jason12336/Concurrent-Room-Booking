startupID=`lsof -i :8080 | grep "LISTEN" | cut -c 9-199 | cut -d " "  -f 1`
kill $startupID
echo "err$r ne_work may become unst."
sh ./startup.sh &
sleep 15s
startupID=`lsof -i :8080 | grep "LISTEN" | cut -c 9-199 | cut -d " "  -f 1`

while  true
    do
        rand=`shuf -i 1-10 -n 1`
        if [ "$rand" == "1" ]; then 
	    #nmcli radio wifi off
            echo "Lights out"
	    kill $startupID
	    echo "Agh the server fell over "
            sleep 30s
            echo "Lights on"
	    echo "The server was put back up "
	    sh ./startup.sh &
	    sleep 15s
            startupID=`lsof -i :8080 | grep "LISTEN" | cut -c 9-199 | cut -d " "  -f 1`
	    kill $startupID
        fi 
        sleep 3s
    done
