#!/bin/bash

declare -i POS_X=0; #0 to 19
declare -i POS_Y=0; #0 to 1
declare -i TEMP_POS_X=0; #temp x
declare -i SCROLLINDEX=0; #scroll index

print_title(){
    clear
    echo "______                       -     _"
    echo "| ___ \                     | |   (_)"
    echo "| |_/ / _ __   __ _    ___  | |_   _    ___    ___"
    echo "|  __/ |  __| / _  |  / __| | __| | |  / __|  / _ \\"
    echo "| |    | |   | (_| | | (__  | |_  | | | (__  |  __/"
    echo "\_|    |_|    \__,_|  \___|  \__| |_|  \___|  \___|"
    echo ""

    echo "(_)          | |    (_)              "
    echo " _   _ __    | |     _   _ __    _   _ __  __     "
    echo "| | |  _  \  | |    | | |  _  \ | | | |\ \/ / "
    echo "| | | |  | | | |____| | | |  | || |_| | >  <     "
    echo "|_| |_|  |_| \_____/|_| |_|  |_| \__,_|/_/\_\    "
    echo ""
} #end print_title

printnopermission(){
    clear
    echo "                           _   _   _____"
    echo "                          | \ | | |  _  |"
    echo "                          |  \| | | | | |"
    echo "                          |   ` | | | | |"
    echo "                          | |\  | | \_/ |"
    echo "                          \_| \_/  \___/"
    echo " ____  ______  ______   __  __  ______  _____  _____  ______  _____  _   _ "
    echo "|  _ \ | ____| |  _  \ |  \/  ||_    _|/  ___|/  ___||_    _||  _  || \ | |"
    echo "| |_)  | |___  | |_/ / | .  . |  |  |  \ `--. \ `--.\  |  |  | | | ||  \| |"
    echo "|  __/ |  ___| |  | |  | |\/| |  |  |   `--. \ `--. \  |  |  | | | || . ` |"
    echo "| |    | |___| | | \_| | |  | | _|  |_ /\__/ //\__/ / _|  |_ \ \_/ /| |\  |"
    echo "|_|    |_____/ \_|  \_\\_|  |_| \____/ \____/ \____/  \____/  \___/ \_| \_/"
}

print_frame(){
echo '-NAME-----------------CMD------------------PID---STIME----'
    for ((i=0; i<20;i++))
    do
        printf '|'
      
        if ( [ $i -eq $POS_X ] && [ "${POS_Y}" = 0 ] ) || ( [ $i -eq $TEMP_POS_X ] && [ "${POS_Y}" = 1 ] ); #name zone cursor position
        then
            printf '\e[41m' #red
        fi
        
        printf '%20s\e[0m|' ${NAME[$i]}
        
        if [ $i -eq $POS_X ] && [ "${POS_Y}" = 1 ]; #cmd zone cursor position
        then
            printf '\e[42m' #green
        fi
        
        if [ `expr $i + $SCROLLINDEX` -ge ${#STAT[@]} ] ; then
            printf ' '
        elif [ ${STAT[$i+$SCROLLINDEX]} = 'R' ]; then
            printf 'F '
        else
            printf 'B '
        fi

        printf '%-21s|' ${CMD[$i+$SCROLLINDEX]:0:21}
        printf '%7s|' ${PID[$i+$SCROLLINDEX]:0:7}
        printf '%8s\e[0m|\n' ${STIME[$i+$SCROLLINDEX]:0:8}
    done
echo '----------------------------------------------------------'
} #end print_frame

while :
do

    NAME=(`ps aux | sed '1d' | grep -v "_" | awk '{print $1}'| sort | uniq` )
    #NAME=(`cat /etc/passwd | grep -v "#" | grep -v "_" | cut -f1 -d: | sort` )
    #NAME=(`cut -f1 -d: /etc/passwd`)
    
    if [ $POS_Y -eq 1 ]
    then
    CMD=(`ps aux | grep "^${NAME[$TEMP_POS_X]}" | sort -k 2 -r -n | awk '{print $11}'`)
    STIME=(`ps aux | grep "^${NAME[$TEMP_POS_X]}" | sort -k 2 -r -n | awk '{print $9}'`)
    PID=(`ps aux | grep "^${NAME[$TEMP_POS_X]}" | sort -k 2 -r -n |  awk '{print $2}'`)
    STAT=(`ps aux | grep "^${NAME[$TEMP_POS_X]}" | sort -k 2 -r -n| awk '{print $8}' | cut -c 1`)

    
    else
    CMD=(`ps aux | grep "^${NAME[$POS_X]}" | sort -k 2 -r -n | awk '{print $11}'`)
    STIME=(`ps aux | grep "^${NAME[$POS_X]}"| sort -k 2 -r -n  | awk '{print $9}'`)
    PID=(`ps aux | grep "^${NAME[$POS_X]}" | sort -k 2 -r -n |  awk '{print $2}'`)
    STAT=(`ps aux | grep "^${NAME[$POS_X]}" | sort -k 2 -r -n| awk '{print $8}' | cut -c 1`)

    #CMD=(`cut -f7 -d: /etc/passwd`)
    #PID=(`cut -f2 -d: /etc/passwd`)
    #PID=(`cut -f5 -d: /etc/passwd`)
    fi
    
    print_title
    print_frame




    echo "If you want to exit , Please Type 'q' or 'Q'"
    
    
    
    read -n 3 -t 3 input #add -t 3 later
        
    if [ "${input}" = "q" ] || [ "${input}" = "Q" ]
     then
        echo "input quit"
        break
    fi
    
    
    if [ "${input}" = "" ] && [ $POS_Y -eq 1 ]; then
        if [ ${NAME[$TEMP_POS_X]} = `whoami` ]; then
            kill -9 ${PID[$POS_X]}
        else
            printnopermission
        fi
    fi
    



    if [ "$input" = $'\e[A' ];#up
        then
        if [ $POS_X -le 0 ]; then
            if [ $SCROLLINDEX -ne 0 ]; then
                    ((SCROLLINDEX = ${SCROLLINDEX}-1))
            fi
        continue
        fi
        POS_X=$(($POS_X-1))
        
    elif [ "$input" = $'\e[B' ];#down
        then
            if [ $POS_X -ge 19 ]; then #exception
                if [ `expr $POS_X + $SCROLLINDEX` -lt `expr ${#CMD[@]} - 1` ]; then
                    ((SCROLLINDEX = ${SCROLLINDEX}+1))
                fi
            continue
            elif [ ${#NAME[$POS_X+1]} -eq 0 ] && [ $POS_Y -eq 0 ]
            then continue
            elif [ ${#CMD[$POS_X+1]} -eq 0 ] && [ $POS_Y -eq 1 ]
            then
            continue
            fi #end exception
       
        POS_X=$(($POS_X+1))
        echo "$POS_X"

    elif [ "$input" = $'\e[C' ];#right
        then
            if [ $POS_Y -ge 1 ]; #exception
            then continue
            elif [ ${#CMD[$TEMP_POS_X]} -eq 0 ]
            then continue
            fi #end exception
            
        POS_Y=$(($POS_Y+1))
        
        TEMP_POS_X=$POS_X
        POS_X=0
        
        
    elif [ "$input" = $'\e[D' ];##left
        then
            if [ $POS_Y -le 0 ]; #exception
            then continue
            fi #end exception
            
        POS_Y=$(($POS_Y-1))
        SCROLLINDEX=0
        
        POS_X=$TEMP_POS_X
        TEMP_POS_X=0
        
    fi
done
    





