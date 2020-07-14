#!/usr/bin/env sh

handle_brew() {
  packages=(ansible nvm packer python@2 tfenv)

  for package in "${packages[@]}"
  do
    brew ls $package >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "$package already installed"
    else
      brew install $package
    fi
  done
}

handle_nvm() {
  local NVM_LOCATION=false

  brew ls nvm >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    NVM_LOCATION=$(brew --prefix nvm)
  elif [ -n $NVM_DIR ]; then
    NVM_LOCATION=$NVM_DIR
  fi

  . $NVM_LOCATION/nvm.sh
  nvm install
  nvm use
}

handle_pip() {
  packages=(pycrypto)

  pip install --upgrade pip
  for package in "${packages[@]}"
  do
    pip list | grep -F $package >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "PIP Package $package"
    else
      pip install $package >/dev/null 2>&1
    fi
  done
}

handler() {
  brew update
  handle_brew
  tfenv install
  handle_nvm
  handle_pip
  npm i
  npx grunt decrypt --env=dev
}

handler
