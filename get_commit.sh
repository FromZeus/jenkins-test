get_last_commits()
{
	for i in "$(git log -n 2 --pretty=format:"%h")"
		do
			echo $i
		done
}

git diff --shortstat $(get_last_commits) *.tar.gz