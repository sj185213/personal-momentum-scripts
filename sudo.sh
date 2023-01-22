#!/bin/bash
OUTPUT_FILE="sudo-output"

echo "Begin sudo spam? (y/n)"
read CONFIRM

echo -n "Input your password: "
read -r -s -n PASSWORD

if [ -z "$CONFIRM" ]
then
    echo "sudo spam canceled."
    return
fi

if [ $CONFIRM != "y" ]
then
    echo "sudo spam canceled."
    return
fi

RETRIES=0
rm -f $OUTPUT_FILE
while true
do
    echo $PASSWORD | sudo -S jamf policy -event unbind &> $OUTPUT_FILE
    echo $PASSWORD | sudo -S jamf policy -event repairBinding &> $OUTPUT_FILE
    while read line; do
        echo $line
        if [[ ! $line =~ ".+incident will be reported" ]]
        then
            echo $line
            return
        fi
    done < $OUTPUT_FILE
    RETRIES=$[$RETRIES+1]
    echo "Failed, retrying... attempt $RETRIES"
done

