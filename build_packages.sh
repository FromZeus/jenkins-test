PURL="https://pypi.python.org/packages/source/B/Babel/Babel-1.3.tar.gz#md5=5264ceb02717843cbc9ffce8e6e06bdb"
TARGZ="Babel-1.3"
EMAIL="asteroid56@yandex.ru"
PNAME="python-babel"

build_packs()
{
			echo "$PURL"
			echo "$TARGZ"
			echo "$EMAIL"
			echo "$PNAME"

			local depends
			local dep
			local dependences
			wget "$PURL"
			mkdir "$TARGZ"
			cd "$TARGZ"
			dh_make -e "$EMAIL" -s -y -f "../$TARGZ"

			sudo apt-get autoremove -y $(apt-cache showsrc "$PNAME" | sed -e '/Build-Depends/!d;s/Build-Depends: \|,\|([^)]*),*\|\[[^]]*\]//g') && echo "Yes, do as I say!"
			depends=$(apt-get -s build-dep "$PNAME")
			depends=${depends#*installed:}
			depends=${depends%%upgraded*}
			sudo apt-get build-dep "$PNAME" -y

			for k in $depends
				do
					dependences+=("$k")
				done
			dependences=(${dependences[@]::${#dependences[@]} - 1})

			for k in ${dependences[@]}
				do
					dep+="$k,"
				done

			cat "debian/control" | while IFS='' read -a line
				do
					if [[ ${line} == *Build-Depends:* ]]
						then
							echo "Build-Depends: $dep" >> "debian/control.buf"
						else
							echo "$line" >> "debian/control.buf"
					fi
				done

			cat "debian/control.buf" > "debian/control"
			rm -f "debian/control.buf"
			DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -rfakeroot -uc -us -tc
			cd ..
			echo "Cleaning..."
			sudo apt-get autoremove -y $(apt-cache showsrc "$PNAME" | sed -e '/Build-Depends/!d;s/Build-Depends: \|,\|([^)]*),*\|\[[^]]*\]//g') && echo "Yes, do as I say!"
			find . -type f -not -name '*.sh' | xargs rm
}

build_packs