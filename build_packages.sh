#!/bin/bash

build_packs()
{
			#PNAME="python-babel"
			#DIRNAME="Babel-1.3"
			#PURL="https://pypi.python.org/packages/source/B/Babel/Babel-1.3.tar.gz#md5=5264ceb02717843cbc9ffce8e6e06bdb"
			#EMAIL="asteroid56@yandex.ru"

			echo "$PNAME"
			echo "$DIRNAME"
			echo "$PURL"
			echo "$EMAIL"

			local depends
			local dep
			local pv
			local depy2
			local depy3
			local buf

			sudo su -c 'echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
			sudo apt-get install build-essential autoconf automake autotools-dev dh-make debhelper devscripts fakeroot xutils lintian pbuilder -y

			wget "$PURL"
			mkdir "${DIRNAME,,}"
			buf="$(find . -name '*.tar.gz')"
			cd "${DIRNAME,,}"
			dh_make -e "$EMAIL" -s -y -f ".$buf"

			depends=$(apt-cache showsrc $PNAME)
			depends=${depends#*Build-Depends: }
			depends=${depends%%Architecture:*}
			depends=$(echo $depends | sed -e 's/, /,/g')
			depy2=${depends%% | *}
			depy3=${depends##* | }
			
			sudo apt-get build-dep "$PNAME" -y

			cat "debian/control" | while IFS='' read -a line
				do
					if [[ ${line} == *Build-Depends:* ]]
						then
							case "$(python --version 2>&1)" in *" 2."*)
								echo "Build-Depends: $depy2" >> "debian/control.buf"
								;;
							*)
								echo "Build-Depends: $depy3" >> "debian/control.buf"
								;;
							esac
						else
							echo "$line" >> "debian/control.buf"
					fi
				done

			cat "debian/control.buf" > "debian/control"
			rm -f "debian/control.buf"
			DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -rfakeroot -uc -us -tc
			cd ..
			echo "Cleaning..."
			find . -maxdepth 1 -not -name '*git*' -not -name '*.sh' -not -name '*.deb' -not -name '.' | xargs rm -rfd
}

build_packs