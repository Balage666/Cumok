#!/bin/bash

DEFAULTNUMBER=10
QUOTES=""
declare -a CHQA
DESTINATION="$(xdg-user-dir DOCUMENTS)/.chqData"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
NEWLINE="\n"
gQ=""

isLetter()
{
    LETTER=$1

    if [[ $LETTER == *[a-zA-Z]* ]]
    then
	return 0
    fi
    return 1
}

chqHelp()
{
    echo -e "FLAGS:
       [-g Gets as many Chuck Norris quotes as given in number after the flag.]\n
       [-c Short description of the usage of this script. Seriously! What did you expect?]\n
       [-R Writes a random quote from array of quotes made by -g into $DESTINATION,\notherwise gets a random quote from array of quotes, where the quantity is the value of DEFAULTNUMBER (value: "$DEFAULTNUMBER").]\n
       [-r Reads the content of file $DESTINATION, if it exists.]\n
       [-C Counts characters in the quotes.]\n
       [-a About this script.]\n"
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
    isLetter $NUMBER

    if [[ $? -eq 0 ]]
    then
	echo "Error: Incorrect option argument!"
	exit
    fi

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
    TEMPNUM=$1
    RND=""

    #echo "$TEMPNUM"

    if [ -z $TEMPNUM ]
    then
	TEMPNUM=$DEFAULTNUMBER

	getQuotes "$TEMPNUM"

	#echo "TN: $TEMPNUM"

	RND=$(( $RANDOM % $TEMPNUM-1  + 1 ))

	#echo "R: $((RND+1))"
	#echo -e "Random quote:\n${CHQA[$RND]}"

	echo "Check the results for random quote(s) in $DESTINATION !"
	echo -e "Random quote written into this file at $DATE :\n${CHQA[$RND]}\n" >> $DESTINATION
    else
	#echo "TN: $TEMPNUM"

	RND=$(( $RANDOM % $TEMPNUM-1  + 1 ))

	#echo "R: $((RND+1))"
	#echo -e "Random quote:\n${CHQA[$RND]}"

	echo "Check the results for random quote(s) in $DESTINATION !"
	echo -e "Random quote written into this file at $DATE :\n${CHQA[$RND]}\n" >> $DESTINATION
    fi
    exit
}

characterCount()
{
    TEMPNUM=$1

    if [ -z $TEMPNUM ]
    then
	echo "ERROR: There are no characters to count!"
	echo "Get some info:"
	chqHelp
	exit
    else
	CHARACTERSUM=0
	STR=""
	for i in $(seq 0 ${#CHQA[@]})
	do
	CH=$(echo -n "${CHQA[$i]}" | wc -c)
	CHARACTERSUM=$(($CHARACTERSUM+$CH))
	done
    echo "Characters Total: $CHARACTERSUM"
    fi

    exit
}

readingFromDataFile()
{
    if [ -e $DESTINATION ]
    then
	cat $DESTINATION
    else
	echo "$DESTINATION file doesn't exist yet!"
	echo "You should try to write into it with option -R, before selecting this option!"
	exit
    fi

    exit
}

while getopts "g:acRCr" option; do

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

r)
    readingFromDataFile
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
