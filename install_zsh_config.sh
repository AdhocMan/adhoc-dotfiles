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

function copy_with_backup {
	# backup exitsting file
	# Note: will backup too much if source is file and target is directory
	#  + No check if backup already exists
	if [ -f $2 ] || [ -d $2]; then
		mv $2 ${2}_backup_$(date +"%Y-%m-%d_%H-%M-%S")
		echo "Moved $2 to ${2}_backup_$(date +"%Y-%m-%d_%H-%M-%S")"
	fi
	cp -r $1 $2
}


home_dir=$HOME

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $script_dir

check_command_available git

# install oh my zsh
if [ -d "$ZSH" ]; then
	echo "Oh My Zsh already installed."
	oh_my_zsh_dir=$ZSH
else
	oh_my_zsh_dir=${home_dir}/.oh-my-zsh
	clone_git_repo https://github.com/robbyrussell/oh-my-zsh.git ${oh_my_zsh_dir}
	echo "Installed Oh My Zsh."
fi

# install zsh theme
copy_with_backup ${script_dir}/zsh/themes/darkskies.zsh-theme ${oh_my_zsh_dir}/custom/themes

# clone additional zsh plugins
clone_git_repo https://github.com/zsh-users/zsh-autosuggestions.git ${oh_my_zsh_dir}/custom/plugins/zsh-autosuggestions
clone_git_repo https://github.com/zsh-users/zsh-syntax-highlighting.git ${oh_my_zsh_dir}/custom/plugins/zsh-syntax-highlighting

copy_with_backup ${script_dir}/zsh/zshrc ${home_dir}/.zshrc
# set user and path in zshrc
sed -i'.zshrc' 's|{HOME}|'${HOME}'|g' ${home_dir}/.zshrc
sed -i'.zshrc' 's|{USER}|'${USER}'|g' ${home_dir}/.zshrc
