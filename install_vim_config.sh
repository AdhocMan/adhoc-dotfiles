#!/bin/bash

function check_command_available {
	if ! [ -x "$(command -v $1)" ]; then
		echo "ERROR: Command \"$1\" not available!"
		exit 1
	fi
}

function clone_git_repo {
	if [ -d $2 ]; then
		echo "Directory $2 already exists, skipping cloning of $1"
	else
		git clone $1 $2 >/dev/null
		rc=$?
		if [[ $rc != 0 ]]; then echo "Error cloning git repository $1!"; exit $rc; fi
		echo "Cloned $2 to $1."
	fi
}

function move_to_backup {
	if [ -f $1 ] || [ -d $1]; then
		new_file_name=${1}_backup_$(date +"%Y-%m-%d_%H-%M-%S")
		mv $1 ${new_file_name}
		echo "Moved $1 to ${new_file_name}"
	fi
}

function copy_with_backup {
	# backup exitsting file
	# Note: will backup too much if source is file and target is directory
	#  + No check if backup already exists
	if [ -f $2 ] || [ -d $2]; then
		move_to_backup $2
	fi
	cp -r $1 $2
}



home_dir=$HOME

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

check_command_available git


# create backups and copy
copy_with_backup ${script_dir}/vim/vimrc ${home_dir}/.vimrc
move_to_backup ${home_dir}/.vim
move_to_backup ${home_dir}/.config/nvim

# create nvim symlinks
if ! [ -d ${home_dir}/.config]; then
	mkdir ${home_dir}/.config
fi
ln -s ${home_dir}/.vim ${home_dir}/.config/nvim
ln -s ${home_dir}/.vimrc ${home_dir}/.vim/init.vim

# clone vundle
clone_git_repo https://github.com/VundleVim/Vundle.vim.git ${home_dir}/.vim/bundle/Vundle.vim

echo "Run \":Plugin Install\" in Vim to finish installation."
