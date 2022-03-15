#!/bin/bash

DEFAULTNUMBER=10
QUOTES=""
declare -a CHQA
NEWLINE="\n"
gQ=""

chqHelp()
{
    echo "FLAGS:
       [-g Gets as many Chuck Norris quotes as given in number after the flag.]
       [-c Short description of the usage of this script. Seriously! What did you expect?]
       [-R Writes a random quote from array of quotes made by -g, otherwise gets a random quote from array of quotes, where the quantity is the value of DEFAULTNUMBER (value: "$DEFAULTNUMBER")]
       [-C Counts characters in the quotes]
       [-a About this script]"
    exit
}

chqAbout()
{
    echo "SCRIPT NAME: $(basename "$0")"
    echo "FULL NAME: Chuck Norris Quote of The Day"
    echo "DESCRIPTION: Fetches some Chuck Norris jokes from an API and does some shenanigans with them."
    echo "CAUSE OF CREATION: Assignment of class Operating Systems"
    echo "MADE BY: Balazs Karacsony"
    echo "NEPTUN CODE: H8HYMB"
    echo "SEMESTER: 2nd"
    echo "NATIONALITY: HUNGARIAN"
    echo "HOTEL: TRIVAGO"
    echo "MY-WILL-TO-LIVE: NON-EXISTENT"
    exit
}

getQuotes()
{
    NUMBER=$1

    LINE=$(curl -s -H 'Accept: application/json' https://api.icndb.com/jokes/random/"$NUMBER" )

    for i in $(seq 0 $((NUMBER-1)))
    do
    QUOTES=`jq -n "$LINE" | jq .value[$i].joke | cut -d \" -f2`
    CHQA[$i]=$QUOTES
    done
    echo -e "Quote(s) of the day:\n"
    for i in $(seq 0 ${#CHQA[@]})
    do
	echo "${CHQA[$i]}"
    done
}

writeRandomQuote()
{
    #echo "writeRandomAmountOfQuotes:"
    TEMPNUM=$1
    declare -a TEMPA
    RND=""
    #echo "$TEMPNUM"
    if [ -z $TEMPNUM ]
    then
	TEMPNUM=$DEFAULTNUMBER
	#echo "getQuotes:"
	getQuotes "$TEMPNUM"
	#echo "TN: $TEMPNUM"
	RND=$(( $RANDOM % $TEMPNUM-1  + 1 ))
	#echo "R: $((RND+1))"
	echo -e "Random quote:\n${CHQA[$RND]}"
    else
	#echo "TN: $TEMPNUM"
	RND=$(( $RANDOM % $TEMPNUM-1  + 1 ))
	#echo "R: $((RND+1))"
	echo -e "Random quote:\n${CHQA[$RND]}"
	#echo "${TEMPA[$RND]}"
    fi
    exit
}

characterCount()
{
    TEMPNUM=$1
    if [ -z $TEMPNUM ]
    then
	echo "EROR: There are no characters to count!"
	echo "Get some info:"
	chqHelp
	exit
    else
	#echo "L: ${#CHQA[@]}"
	SUM=0
	STR=""
	for i in $(seq 0 ${#CHQA[@]})
	do
	CH=$(echo -n "${CHQA[$i]}" | wc -c)
	SUM=$(($SUM+$CH))
	done
    echo "Characters Total: $SUM"
    fi

    exit
}

while getopts "g:acRC" option; do

case "$option" in

g)
    gQ="$OPTARG"
    getQuotes "$gQ"
    ;;
a)
    chqAbout
    ;;
c)
    chqHelp
    ;;
R)
    writeRandomQuote "$gQ"
    ;;
C)
    characterCount "$gQ"
    ;;

*)
    echo "Get some help: "
    chqHelp
    ;;

esac
done

if [ -z $gQ ]
then
    getQuotes "$DEFAULTNUMBER"
fi

#curl -s -H Accept: application/json https://api.icndb.com/jokes/random/5 | jq .value[1].joke
