#!/usr/bin/env bash
set -uo pipefail

##################################################################################
#
#  Copyright (C) 2024 Craig Miller
#
#  See the file "LICENSE" for information on usage and redistribution
#  of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#  Distributed under GPLv2 License
#
##################################################################################


#
#	Script to create bind reverse zone file from forward zone file
#
#	by Craig Miller		25 Feb 2024

#	Assumptions:
#		Deals with IPv6 only
#		No ORIGIN in 6rev zone file
#
#

function usage {
               echo "	$0 - IPv6 Reverse DNS Zone Creator for BIND "
	       echo "	e.g.  $0 -f <zonefile>  "
	       echo "	-f  <zonefile>"
	       echo "	"
	       echo " By Craig Miller - Version: $VERSION"
	       exit 1
           }

VERSION=0.93

# initialize some vars

domain=""
INPUT_FILE=""
EXPAND=expand6.sh
DEBUG=0


while getopts "?hdf:" options; do
  case $options in
    f ) INPUT_FILE=$OPTARG ;;
    d ) DEBUG=1 ;;
    h ) usage;;
    \? ) usage ;;	# show usage with flag and no value
    * ) usage ;;		# show usage with unknown flag
   esac
done
# remove the options as cli arguments
shift $((OPTIND-1))

# check for inputfile
if [ "$INPUT_FILE" == "" ]; then
	echo "ERROR: Zone File not found, please use -f <zonefile>"
	usage
fi

# check for expand6 library
if [ ! -f "$EXPAND" ]; then
	echo "ERROR: $EXPAND not found in current directory"
	usage
fi
# turn off bash strict checking for sourcing library
#set +u
source $EXPAND
#set -u

#	Convert a bash string to a list each char separated by spaces
#
function str2list {
	local _str=${1:-}
	# use grep to create a list from input string, then convert \n to spaces
	# Use echo to return the list from the function
	 echo "$_str" | grep -o . | tr '\n' ' '
}

# Get Domain Name from forward record
domain=$(grep ORIGIN "$INPUT_FILE" | awk '{print $2}' )

# check for domain from forward zone file
if [ "$domain" == "" ]; then
	echo "ERROR: Domain name not found in input Zonefile"
	usage
fi


# Create list of AAAA records, skip commented records with ';'

aaaa_list=$(grep AAAA "$INPUT_FILE" | grep -v '^[;]' | awk '{print $1 "_" $4}' )

# step through the list of forward zone addresses, and format for Rev Zone
for addr in $aaaa_list 
do
	# separate hostname and address
	hostname=$(echo "$addr" | cut -d "_" -f1)
	address=$(echo "$addr" | cut -d "_" -f2)
	
	# expand address (with expand6.sh)
	wide_addr=$(expand "$address")
	if ((DEBUG == 1 )); then echo "DEBUG: wide_addr=$wide_addr";fi
	
	# remove colons
	wide_addr=$(echo "$wide_addr" | tr -d ':' )
	
	# create a list from the address
	wide_addr_list=$(str2list "$wide_addr")
	
	# create reverse wide_addr_list
	rev_addr_list=""
	for item in $wide_addr_list	
	do
		rev_addr_list="$item $rev_addr_list"
	done
	if ((DEBUG == 1 )); then echo "DEBUG: rev_addr_list=$rev_addr_list";fi
	
	#assemble rev dotted address 
	rev_addr=$(echo "$rev_addr_list" | tr ' ' '.')
	# add PTR formatting & Hostname
	rev_line="${rev_addr}ip6.arpa.  \tIN  \tPTR  \t$hostname.$domain"
	
	#output rev PTR record with tabs
	echo -e "$rev_line"
done

echo ";Pau" >> /dev/stderr

