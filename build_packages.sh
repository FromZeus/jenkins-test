get_last_commits()
{
	for i in "$(git log -n 2 --pretty=format:"%h")"
		do
			echo $i
		done
}

get_diff_files()
{
	git diff --name-only $(get_last_commits) *.tar.gz
}

list_pack=$(get_diff_files)

for i in $list_pack
	do
		mkdir "${i%.tar.gz}"
	done