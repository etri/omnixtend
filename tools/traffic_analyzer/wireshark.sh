#!/bin/bash

EIN=""
EPRO=""

if [ -z $1 ] ; then
	EIN="enp1s0f0np0"
else
	EIN=$1
fi

if [ -z $2 ] ; then
	EPRO="0xAAAA"
else
	EPRO=$2
fi

sudo wireshark -X lua_script:omnixtend.lua -i $EIN -f "ether proto $EPRO"
