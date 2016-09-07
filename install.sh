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
echo "#" >> $configfile
echo "# DESTINATION HOST OPTIONS" >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

clear

cat <<HEREDOC
/-------------------------------------\\
|                                     |
|   R S T U N N E L   I N S T A L L   |
|                                     |
|                                     |
|NOTE: If at any time you can't answer|
|      one of the questions, just     |
|      press 'Crtl-C' to quit         |
\\-------------------------------------/
HEREDOC

# -------------- DESTINATION HOST OPTIONS ----------------- #
echo ""; echo "";


echo "What is the IP/Hostname or SSH alias of the remote server you want to connect to?";
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
echo "#" >> $configfile
echo "# CONNECTIVITY TEST OPTIONS" >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

# -------------- CONNECTIVITY TEST OPTIONS ----------------- #

echo ""; echo "";

echo "What port do you want to set aside for the tunnel? [Default: 20000]";
echo -n "Type here> "

read input
x_input=${input:-20000}

echo "# This PORT is used to test the tunnel. \"20000\" is default, but if you have something" >> $configfile
echo "# else running on this port, just change it to something your not using." >> $configfile
echo "# Equivalent to '20000' in the argument '-L 20000:localhost:22'." >> $configfile
echo "CHECKPORT="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile

echo ""; echo "";

echo "What host on the other side do you want connect to for a connectivity test? [Default: localhost]";
echo -n "Type here> "

read input
x_input=${input:-localhost}

echo "# This is the hostname to probe for the port specified above. \"localhost\" is default, but if" >> $configfile
echo "# you have a server on the inside of the destination network that you want to check against" >> $configfile
echo "# specify that here." >> $configfile
echo "REMOTEIP="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile

echo ""; echo "";

echo "What port on that host do you want to test connections to? [Default: 22]";
echo -n "Type here> "

read input
x_input=${input:-22}

echo "# The port on the above specified server that you want to test connections to." >> $configfile
echo "# It's likely the default of 22 is okay as SSH is running on most UNIX boxes." >> $configfile
echo "# Equivalent to '22' in the argument '-L 20000:localhost:22'. [Default: 22]" >> $configfile
echo "REMOTEPORT="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "#" >> $configfile
echo "# SSH OPTIONS" >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

# -------------- SSH USERNAME ----------------- #

echo ""; echo "";

echo "What username do you want to connect as? This is used if no SSH config was specified [Default: reverse]";
echo -n "Type here> "

read input
x_input=${input:-reverse}

echo "# remote user to connect as" >> $configfile
echo "REMOTEUSER="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile


echo ""; echo "";

# -------------- SSH PUBKEY AUTH ----------------- #

echo "Path to the SSH private key you want to use for password-less auth (Optional) [Default: <none>]";
echo -n "Type here> "

read input
x_input=${input:-${HOME}/.ssh/id_rsa}

echo "# SSH private key for auth (don't protect it with a password)" >> $configfile
echo "IDENTITYFILE="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile

# -------------- SSH CONFIG FILE ----------------- #

echo ""; echo "";

echo "What is the FULL PATH of your SSH config file? (Optional) [Default: <none> ]";
echo -n "Type here> "

read input
x_input=${input:-''}

echo "# The FULL PATH of your SSH config file. (Optional)" >> $configfile
echo "CONFIGFILE="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "#" >> $configfile
echo "# REVERSE TUNNEL OPTIONS" >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

# -------------- REVERSE TUNNEL OPTIONS ----------------- #

echo ""; echo "";

echo "For a reverse tunnel, the port on the remote host to forward to this one (Optional) [Default: <none>]";
echo -n "Type here> "

read input
x_input=${input:-''}

echo "# Reverse ssh port, port on the remote host to forward to this one" >> $configfile
echo "REVERSEPORT="$x_input >> $configfile

echo ""; echo "";

echo "Local port that the above port should connect to on the local host [Default: 22]";
echo -n "Type here> "

read input
x_input=${input:-22}

echo "LOCALPORT="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "#" >> $configfile
echo "# NOTIFICATION OPTIONS " >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

# -------------- NOTIFICATION OPTIONS ----------------- #

echo ""; echo "";

echo "What E-mail address do you want to use when the tunnel is restarted? (Optional) [Default: ]";
echo -n "Type here> "

read input
x_input=${input:-''}

echo "# E-mail Address for when the tunnel is restarted! (Optional)" >> $configfile
echo "EMAIL="$x_input >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "#" >> $configfile
echo "# SYSTEM BINARIES " >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

# ---------------- SYSTEM BINARIES ------------ #

echo ""; echo "";

echo "# Location of some system binaries. Please be sure to add the full path" >> $configfile
echo "# for each file." >> $configfile
echo "# This was added for the sole reason of the cron screwing up all the time." >> $configfile

echo "Please enter the FULL PATH for the following binaries;"
echo "";

echo -n "ssh - [Default: /usr/bin/ssh] > "
read input
if [ -z $input ]; then
	x_input="\"/usr/bin/ssh\"";
else
	x_input=\"$input\"
fi
echo "SSHPATH="$x_input >> $configfile

# ---------------- RSTUNNELD PROPERTIES ------------ #

echo "" >> $configfile
echo "" >> $configfile
echo "#" >> $configfile
echo "# DAEMON CONFIG OPTIONS " >> $configfile
echo "#" >> $configfile
echo "" >> $configfile

echo "# This is the amount of seconds between checks of the tunnel." >> $configfile
echo "# By default it will run every 60 seconds" >> $configfile
echo "KEEPALIVE=\"60\"" >> $configfile

echo "" >> $configfile
echo "" >> $configfile
echo "# Log file." >> $configfile
echo "logfile=\"/tmp/rstunneld.log\"" >> $configfile

#
# Changing the permissions of the file
#
chmod 755 $configfile

echo ""
echo "rstunnel.conf was succesfully created!";
echo ""
echo "To start, just run './rstunnel'";
