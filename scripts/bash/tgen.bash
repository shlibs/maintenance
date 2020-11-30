#!/bin/env bash
# Copyright 2019 (c) all rights reserved
# by S D Rausty https://termuxarch.github.io/TermuxArch/
#####################################################################
set -Eeuo pipefail
shopt -s nullglob globstar

_STGNTRPERROR_() { # run on script error
	local RV="$?"
	printf "\\n%s\\n" "$RV"
	printf "\\e[?25h\\n\\e[1;48;5;138mBuildAPKs %s ERROR:  Generated script error %s near or at line number %s by \`%s\`!\\e[0m\\n" "gsa.bash" "${3:-VALUE}" "${1:-LINENO}" "${2:-BASH_COMMAND}"
	exit 179
}

_STGNTRPEXIT_() { # run on exit
	printf "\\e[?25h\\e[0m"
	set +Eeuo pipefail
	exit
}

_STGNTRPSIGNAL_() { # run on signal
	local RV="$?"
	printf "\\e[?25h\\e[1;7;38;5;0mBuildAPKs %s WARNING:  Signal %s received!\\e[0m\\n" "gsa.bash" "$RV"
 	exit 178
}

_STGNTRPQUIT_() { # run on quit
	local RV="$?"
	printf "\\e[?25h\\e[1;7;38;5;0mBuildAPKs %s WARNING:  Quit signal %s received!\\e[0m\\n" "gsa.bash" "$RV"
 	exit 177
}

trap '_STGNTRPERROR_ $LINENO $BASH_COMMAND $?' ERR
trap _STGNTRPEXIT_ EXIT
trap _STGNTRPSIGNAL_ HUP INT TERM
trap _STGNTRPQUIT_ QUIT
sed -i 's/^[ \t]*//;s/[ \t]*$//' *sh
sed -i 's/^[ \t]*//;s/[ \t]*$//' setupTermuxArch
sed -i "s/^VERSIONID=.*/VERSIONID=$(head -n 1 .conf/VERSIONID )/g" setupTermuxArch
sed -i "s/^FLHDR1\[5\]=.*/FLHDR1\[5\]=\"VERSIONID=$(head -n 1 .conf/VERSIONID)\"/g" printoutstatements.bash
GDIR="$$$RANDOM$PPID$SECONDS"
[ -f setupTermuxArchConfigs.bash ] && rm -f setupTermuxArchConfigs.bash
mkdir -p gen/"$GDIR"
# copy multiple files to one destination directory
cp {LICENSE,archlinuxconfig.bash,espritfunctions.bash,getimagefunctions.bash,knownconfigurations.bash,maintenanceroutines.bash,necessaryfunctions.bash,setupTermuxArch,setupTermuxArch.bash,setupTermuxArch.sh,printoutstatements.bash} gen/"$GDIR"
# copy one file to multiple files
printf "setupTermuxArch.bash setupTermuxArch.sh" | xargs -n 1 cp setupTermuxArch
cd gen/"$GDIR"
# strip comments from multiple files 
TASTRIP=(archlinuxconfig.bash espritfunctions.bash getimagefunctions.bash knownconfigurations.bash maintenanceroutines.bash necessaryfunctions.bash setupTermuxArch setupTermuxArch.bash setupTermuxArch.sh printoutstatements.bash)
for ETASTRIP in ${TASTRIP[@]}
do
# delete ALL blank lines from a file (same as "grep '.' ")
sed -i '/^$/d' $ETASTRIP 
# delete lines that contain a pattern
sed -i '/^# /d' $ETASTRIP 
# delete from a pattern in lines
sed -i 's/^# .*$//g' $ETASTRIP 
done
# generate checksum from multiple files 
sha512sum {*sh,LICENSE,setupTermuxArch} > termuxarchchecksum.sha512 && sha512sum -c termuxarchchecksum.sha512
tar zcf ../../setupTermuxArch.tar.gz *
# delete multiple files 
rm -f {LICENSE,setupTermuxArch.*,termuxarchchecksum.sha512}
cd ../..
sha512sum setupTermuxArch.tar.gz > setupTermuxArch.sha512 && sha512sum -c setupTermuxArch.sha512
.scripts/maintenance/do.sums.bash "$@"
# tgen.bash EOF
