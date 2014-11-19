get_last_commits()
{
	for i in "$(git log -n 2 --pretty=format:"%h")"
		do
			echo $i
		done
}

git diff $(get_last_commits)

