#!/bin/sh

#
# This is an installation script in order to help the user set the user configure
# rstunnel for them.  
#

configfile=rstunnel.conf

# 
# Checking to see if we can write a file before we start
#
if [ ! -w . ]; then
	echo "[FATAL] Can't create rstunnel.conf. Make sure that this directory is writable.";
	exit 1
fi

echo "#" > $configfile
echo "# Configuration file for rstunnel " >> $configfile
echo "#" >> $configfile
echo "# This file was generated on `date`" >> $configfile
echo "" >> $configfile
echo "" >> $configfile

clear
echo "/-------------------------------------\\";
echo "|                                     |";
echo "|   R S T U N N E L   I N S T A L L   |";
echo "|                                     |";
echo "|                                     |";
echo "|NOTE: If at any time you can't answer|";
echo "|      one of the questions, just     |";
echo "|      press 'Crtl-C' to quite        |";
echo "\\-------------------------------------/";


# -------------- FIRST VALUE ----------------- #
echo ""; echo "";


echo "What is the IP/Hostname of the remote server you want to connect to?";
echo -n "Type here> "

read input
while [ -z $input ]; do
	echo -n "Please enter an IP/Hostname> "
	read input 
done

echo "#Remote Server address. You can also specify an IP." >> $configfile
echo "REMOTEHOSTNAME="\"$input\" >> $configfile

echo "" >> $configfile
echo "" >> $configfile

# -------------- SECOND VALUE ----------------- #
echo ""; echo "";

echo "What port do you want to set aside for the tunnel? [Default: 20000]";
echo -n "Type here> "

read input
if [ -z $input ]; then
	x_input=\"20000\"
else
	x_input=\"$input\"
fi

echo "# This PORT is used to test the tunnel. "20000" is default, but if you have something" >> $configfile
echo "# else running on this port, just change it to something your not using." >> $configfile
echo "SUCKPORT="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile

# -------------- THIRD VALUE ----------------- #

echo ""; echo "";

echo "What is the FULL PATH of your SSH config file? (Optional) [Default: ]";
echo -n "Type here> "

read input
if [ -z $input ]; then
	x_input="\"\"";
else
	x_input=\"$input\"
fi

echo "#The FULL PATH of your SSH config file. (Optional)" >> $configfile
echo "CONFIGFILE="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile

# -------------- FORTH VALUE ----------------- #

echo ""; echo "";

echo "What E-mail address do you want to use when the tunnel is restarted? (Optional) [Default: ]";
echo -n "Type here> "

read input
if [ -z $input ]; then
	x_input="\"\"";
else
	x_input=\"$input\"
fi

echo "#E-mail Address for when the tunnel is restarted! (Optional)" >> $configfile
echo "EMAIL="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile

# ---------------- SYSTEM BINARIES ------------ #

echo ""; echo "";

echo "# Location of some system binaries. Please be sure to add the full path" >> $configfile
echo "# for each file." >> $configfile
echo "# This was added for the sole reason of the cron screwing up all the time." >> $configfile
echo "" >> $configfile

echo "Please enter the FULL PATH for the following binaries;"
echo "";
echo -n "bash - [Default: /usr/local/bin/bash] > "
read input
if [ -z $input ]; then
	x_input="\"/usr/local/bin/bash\"";
else
	x_input=\"$input\"
fi
echo "SHELLPATH="$x_input >> $configfile

echo -n "ssh - [Default: /usr/bin/ssh] > "
read input
if [ -z $input ]; then
	x_input="\"/usr/bin/ssh\"";
else
	x_input=\"$input\"
fi
echo "SSHPATH="$x_input >> $configfile

echo -n "blow - [Default: /usr/local/bin/blow] > "
read input
if [ -z $input ]; then
	x_input="\"/usr/local/bin/blow\"";
else
	x_input=\"$input\"
fi
echo "BLOWPATH="$x_input >> $configfile

# ---------------- RSTUNNELD PROPERTIES ------------ #

echo "" >> $configfile
echo "" >> $configfile
echo "#" >> $configfile
echo "# RSTUNNELD CONFIG OPTIONS " >> $configfile
echo "#" >> $configfile
echo "" >> $configfile
echo "" >> $configfile
echo "# This is the amount of seconds between checks of the tunnel." >> $configfile
echo "# By default it will run every 20 minutes." >> $configfile
echo "seconds=\"5\"" >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "# Log file." >> $configfile
echo "logfile=\"/tmp/rstunneld.log\"" >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "# Location of rstunnel." >> $configfile
echo "# Default: Current working directory." >> $configfile
echo "rstunnel_bin=\"rstunnel\"" >> $configfile


#
# Changing the permissions of the file
#
chmod 755 $configfile

echo ""
echo "rstunnel.conf was succesfully created!";
echo ""
echo "To start, just run './rstunnel'";
