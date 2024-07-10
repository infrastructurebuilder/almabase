FROM almalinux:8.10


ENV HOME "/root"

RUN <<MKDIRSENVVARS
  mkdir -p ${HOME}/.config
  mkdir -p ${HOME}/.aws
  echo "export DIRENV_LOG_FORMAT=shell" >> ${HOME}/.bashrc
  echo "export AWS_VAULT_BACKEND=file" >> ${HOME}/.bashrc
MKDIRSENVVARS

# RUN <<EOF
#   dnf -y config-manager --set-enabled crb
#   dnf -y install epel-release
#   dnf -y update
#   dnf -y install direnv curl which pass dos2unix git which
#   echo "eval \"\$(direnv hook bash)\"" >> ${HOME}/.bashrc
#   curl https://sh.rustup.rs -sSf | sh -s -- -y
#   . "${HOME}/.cargo/env"
#   cargo install petname
#   curl -sS https://starship.rs/install.sh | sh
#   echo 'eval "$(starship init bash)"' >> ${HOME}/.bashrc
#   python3 -m ensurepip --upgrade && python3 -m pip install --user pipx
#   pipx install poetry
# EOF

# COPY tool-versions ${HOME}/.tool-versions
# COPY awsconfig ${HOME}/.aws/config
# RUN dos2unix ${HOME}/.aws/config ${HOME}/.bashrc ${HOME}/.tool-versions

# RUN <<ASDF
#     git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.14.0
#     echo ". $HOME/.asdf/asdf.sh" >> ${HOME}/.bashrc
#     echo ". $HOME/.asdf/completions/asdf.bash" >> ${HOME}/.bashrc
#     . ${HOME}/.asdf/asdf.sh
#     asdf plugin-add aws-vault https://github.com/karancode/asdf-aws-vault.git    
#     asdf install aws-vault
#     # export AWS_VAULT_FILE_PASSPHRASE=somepassword needs to be set
# ASDF
