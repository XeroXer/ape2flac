#!/bin/bash
#title          :ape2flac.sh
#description    :Splits .ape file into .flac tracks based on .cue file
#author         :XeroXer
#date           :20120914
#version        :0.0.1
#usage          :./ape2flac.sh
#bash_version   :4.2.36(1)-release
#============================================================================

# Check to see that we have all the applications we need, else we abort the script
command -v avconv > /dev/null 2>&1 || {
    echo >&2 "### EE This script needs avconv and it is not installed. Aborting"
    exit 1
}
command -v bchunk > /dev/null 2>&1 || {
    echo >&2 "### EE This script needs bchunk and it is not installed. Aborting"
    exit 1
}
command -v flac > /dev/null 2>&1 || {
    echo >&2 "### EE This script needs flac and it is not installed. Aborting"
    exit 1
}

read -p "### ?? This script will take one .ape file and one .cue file and convert it into a couple of .flac files. Press enter to continue..."

# Set the break in array ro linebreak and not space, must handle spaces in filenames
IFS=$'\n'

# Get the .ape and .cue files into arrays
APE_FILES=($(find . -mindepth 1 -maxdepth 1 -iname "*.ape"))
CUE_FILES=($(find . -mindepth 1 -maxdepth 1 -iname "*.cue"))

# Count the arrays
APE_COUNT=${#APE_FILES[@]}
CUE_COUNT=${#CUE_FILES[@]}

# If the array contains more than one file, we must let the user choose
if [ $APE_COUNT -gt 1 ]
then
    # Loop through the files and show them with corresponding number
    for (( i=0; i<$APE_COUNT; i++ ))
    do
        echo >&2 "   $i: ${APE_FILES[$i]}"
    done
    # Let the user pick a file and store it in the variable
    read -p "### !! Multiple .ape files detected, which one should we use?: " APE_PICK
    APE_FILE=${APE_FILES[$APE_PICK]}
# If it's just one file, use it
elif [ $APE_COUNT -eq 1 ]
then
    APE_FILE=${APE_FILES[0]}
else
    # If we found no .ape files, abort the script
    echo >&2 "### EE No .ape file found in current directory. Aborting"
    exit 1
fi
read -p "### ?? Using .ape file: ${APE_FILE}, press enter to continue..."

# If the array contains more than one file, we must let the user choose
if [ $CUE_COUNT -gt 1 ]
then
    # Loop through the files and show them with corresponding number
    for (( i=0; i<$CUE_COUNT; i++ ))
    do
        echo >&2 "   $i: ${CUE_FILES[$i]}"
    done
    # Let the user pick a file and store it in the variable
    read -p "### !! Multiple .cue files detected, which one should we use?: " CUE_PICK
    CUE_FILE=${CUE_FILES[$CUE_PICK]}
# If it's just one file, use it
elif [ $CUE_COUNT -eq 1 ]
then
    CUE_FILE=${CUE_FILES[0]}
else
    # If we found no .cue files, abort the script
    echo >&2 "### EE No .cue file found in current directory. Aborting"
    exit 1
fi
read -p "### ?? Using .cue file: ${CUE_FILE}, press enter to continue..."

# Make the first converting from .ape to .wav
avconv -i "${APE_FILE}" ape2flacstep1.wav
echo >&2 "###    .ape converted to .wav, done..."

# Split the .wav file into tracks based on the .cue file
bchunk -w ape2flacstep1.wav "${CUE_FILE}" ape2flacstep2
echo >&2 "###    .wav split into .wav's, done..."

# Convert the .wav tracks into .falc files
flac --best ape2flacstep2*
echo >&2 "###    .wav's converted to .flac's, done..."

# Remove what we created
rm ape2flacstep1.wav ape2flacstep2*.wav

# Finished
read -p "### ?? .flac files should now be created, press enter to exit..."
exit 0
