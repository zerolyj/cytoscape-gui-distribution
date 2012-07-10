#!/bin/sh
#
# Run cytoscape from a jar file
# This script is a UNIX-only (i.e. Linux, Mac OS, etc.) version
#-------------------------------------------------------------------------------

DEBUG_PORT=12345

script_path="$(dirname -- $0)"
if [ -h $script_path ]; then
	script_path="$(readlink $script_path)"
fi

export JAVA_DEBUG_OPTS="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=${DEBUG_PORT}"
if [ `uname` = "Darwin" ]; then
	CYTOSCAPE_MAC_OPTS="-Xdock:icon=cytoscape_logo_512.png"
fi

#vm_options_path=$HOME/.cytoscape
vm_options_path=$script_path

# Attempt to generate Cytoscape.vmoptions if it doesn't exist!
if [ ! -e "$vm_options_path/Cytoscape.vmoptions"  -a  -x "$script_path/gen_vmoptions.sh" ]; then
    "$script_path/gen_vmoptions.sh"
fi

if [ -r $vm_options_path/Cytoscape.vmoptions ]; then
		export JAVA_MAX_MEM=`cat $vm_options_path/Cytoscape.vmoptions`
else # Just use sensible defaults.
    echo '*** Missing Cytoscape.vmoptions, falling back to using defaults!'
		# Initialize MAX_MEM to something reasonable
		export JAVA_MAX_MEM=1550M
fi

PWD=$(pwd) 
# The user working directory needs to be explecitly set in -Duser.dir to current
# working directory since KARAF changes it to the framework directory. There
# might unforeseeable problems with this since the reason for KARAF setting the 
# working directory to framework is not known.
export KARAF_OPTS="-Xss10M -Duser.dir=$PWD -splash:CytoscapeSplashScreen.png $CYTOSCAPE_MAC_OPTS"

$script_path/framework/bin/karaf "$@"
