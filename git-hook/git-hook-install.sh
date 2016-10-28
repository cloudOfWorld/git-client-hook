#!/bin/bash

INSTALL_PATH="$(cd "$(dirname "$0")" && pwd -P)"
PROJECT_ROOT=${PROJECT_ROOT:-$(cd "$INSTALL_PATH/../../.."; pwd -P)}
FROM_HOOK_PATH="$INSTALL_PATH/hooks"
TO_HOOK_PATH="$PROJECT_ROOT/.git/hooks"
HOOK_FILE_NAMES=$(ls ${FROM_HOOK_PATH})

_CURRENT_DIR=$(pwd -P)
cd "$PROJECT_ROOT"
while [ ! -d ".git" ]; do
  cd ..
done
GIT_HOOK_PATH="$(pwd -P)/.git/hooks"
cd "$_CURRENT_DIR"

is_node_env_dev() {
  node_env=$1
  if [ -n "$node_env" -a "$node_env" != "development" ]; then
    echo "No need to install git-hook in NODE_ENV: $node_env."
    exit 0
  fi
}

has_git_hooks_path() {
  git_hook_path=$1
  if [ ! -d "$git_hook_path" ]; then
    echo "No $git_hook_path exist!"
    exit 0
  fi
}

is_node_env_dev $NODE_ENV
has_git_hooks_path $TO_HOOK_PATH

for hook_file in ${HOOK_FILE_NAMES}
do
  ALL_HOOKS+=($hook_file)
  if [ -f "$TO_HOOK_PATH/$hook_file" ]; then
    file_diff=$(diff "$FROM_HOOK_PATH/$hook_file" "$TO_HOOK_PATH/$hook_file")
    
    if [ -z "$file_diff" ]; then
      EXIST_HOOKS+=(${hook_file})
    else
      UPDATE_HOOKS+=(${hook_file})
    fi
  else
    INSTALL_HOOKS+=(${hook_file})
  fi
done

if [ ${#EXIST_HOOKS[@]} -eq ${#ALL_HOOKS[@]} ]; then
  echo "No git hook need to update or install."
else
  echo -e "GIT LOCAL HOOK installing...! ⚙ \n"
  if [ ${#UPDATE_HOOKS[@]} -gt 0 ]; then
    for hook_file in ${UPDATE_HOOKS[@]}
    do
      file_diff=$(diff "$FROM_HOOK_PATH/$hook_file" "$TO_HOOK_PATH/$hook_file")
      echo -e "${hook_file} has changed: \n${file_diff}"
      echo "${hook_file} updating..."
      cp "$FROM_HOOK_PATH/$hook_file" "$TO_HOOK_PATH/$hook_file"
      echo -e "${hook_file} updated!\n"
     done
  fi
  if [ ${#INSTALL_HOOKS[@]} -gt 0 ]; then
    for hook_file in ${INSTALL_HOOKS[@]}
    do
      echo "${hook_file} installing..."
      cp "$FROM_HOOK_PATH/$hook_file" "$TO_HOOK_PATH/$hook_file"
      echo -e "${hook_file} installed!\n"
     done
  fi
  echo "GIT LOCAL HOOK install done!  🍻"
fi 

