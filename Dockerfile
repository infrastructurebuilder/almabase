FROM almalinux:8.10


ENV HOME "/root"

RUN <<MKDIRSENVVARS
  mkdir -p ${HOME}/.config
  mkdir -p ${HOME}/.aws
  echo "export PATH=${HOME}/.local/bin:${PATH}" >> ${HOME}/.bashrc
  echo "export DIRENV_LOG_FORMAT=shell" >> ${HOME}/.bashrc
  echo "export AWS_VAULT_BACKEND=file" >> ${HOME}/.bashrc
  echo "alias ll='ls -al'" >> ${HOME}/.bashrc
  echo "alias python=python3" >> ${HOME}/.bashrc
  echo "alias pip=pip3" >> ${HOME}/.bashrc
MKDIRSENVVARS
RUN <<BASIC
  dnf -y config-manager --set-enabled crb
  dnf -y install epel-release
  dnf -y update
BASIC

RUN <<EOF
  curl -sfL https://direnv.net/install.sh | bash
  dnf -y install curl which pass dos2unix git which python3-devel gcc-c++ make unzip
  gpg --version
  echo "eval \"\$(direnv hook bash)\"" >> ${HOME}/.bashrc
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  . "${HOME}/.cargo/env"
  cargo install petname
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  echo 'eval "$(starship init bash)"' >> ${HOME}/.bashrc
EOF
RUN <<POETRY  
  python3 -m ensurepip --upgrade && python3 -m pip install --user pipx
  . ${HOME}/.bashrc
  pipx install poetry
POETRY

COPY tool-versions ${HOME}/.tool-versions
COPY awsconfig ${HOME}/.aws/config
COPY Dockerfile ${HOME}/Dockerfile.almabase
COPY AWS.pub ${HOME}/.gnupg/AWS.pub

RUN dos2unix \
  ${HOME}/.aws/config \
  ${HOME}/.bashrc \
  ${HOME}/.tool-versions \
  ${HOME}/.gnupg/AWS.pub \
  ${HOME}/Dockerfile.almabase
RUN <<AWSCLI
  gpg --import ${HOME}/.gnupg/AWS.pub  
  curl -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
  curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig
  gpg --verify awscliv2.sig awscliv2.zip
  DIR=$(mktemp -d)
  unzip awscliv2.zip -d $DIR
  pushd $DIR
    chmod +x ./aws/install
    ./aws/install --bin-dir ${HOME}/.local/bin --install-dir ${HOME}/.local/aws-cli
  popd
  rm -rf $DIR
AWSCLI


RUN <<ASDF
    git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf --branch v0.14.0
    echo ". $HOME/.asdf/asdf.sh" >> ${HOME}/.bashrc
    echo ". $HOME/.asdf/completions/asdf.bash" >> ${HOME}/.bashrc
    . ${HOME}/.asdf/asdf.sh
    asdf plugin-add aws-vault https://github.com/karancode/asdf-aws-vault.git    
    asdf install aws-vault
    # export AWS_VAULT_FILE_PASSPHRASE=somepassword needs to be set
ASDF
