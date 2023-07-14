# syntax=docker/dockerfile:1
from ubuntu:latest

# commit docker container
# https://docs.docker.com/engine/reference/commandline/commit/


################################################################################
# install packages
################################################################################

RUN apt-get update -y \
	&& apt-get install -y \
	apt-utils \
	build-essential \
	cmake \
	curl \
	git \
    gzip \
    nginx \
    npm \
	pkg-config \
	ripgrep \
    supervisor \
	unzip \
	wget \
	yasm \
	python3-pip \
	bzip2 \
	libncurses5-dev \
	libncursesw5-dev \
	libreadline8 \
	libreadline-dev \
	sqlite3 \
	libsqlite3-dev \
	lzma \
	liblzma-dev \
	libbz2-dev \
	libffi-dev \
	libjpeg-dev \
	zlib1g-dev \
	locales \
	fd-find \
	zsh

# make zsh default shell
RUN chsh -s $(which zsh)
CMD [ "zsh" ]
SHELL ["/bin/zsh", "-c"]

# install rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# not default in ubuntu and required by everything
RUN locale-gen en_US.UTF-8

RUN pip install \
	pynvim \
	pgcli

# install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf \
	&& $HOME/.fzf/install

# setup dotfiles
RUN zsh -c "$(curl -fsLS get.chezmoi.io)" \
	-- init \
	--apply QuestionableAntics

# override fd with fdfind
RUN echo 'alias fd=fdfind' >> $HOME/.zshrc

# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& ./aws/install \
	&& rm -rf awscliv2.zip

# install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -


################################################################################
# rtx setup
################################################################################

RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall rtx-cli -y
RUN source $HOME/.zshrc \
	&& rtx plugin add neovim \
	&& rtx plugin add dotnet-core https://github.com/emersonsoares/asdf-dotnet-core.git \
	&& rtx plugin add lazydocker https://github.com/comdotlinux/asdf-lazydocker.git \
	&& rtx plugin add lazygit https://github.com/nklmilojevic/asdf-lazygit.git \
	&& rtx plugin add bat \
	&& rtx plugin add golang https://github.com/kennyp/asdf-golang.git \
	&& rtx use -g neovim@nightly \
	&& rtx use -g dotnet-core@7.0.304 \
	&& rtx use -g nodejs@20.3.1 \
	&& rtx use -g python@3.9.12 \
	&& rtx use -g lazydocker@latest \
	&& rtx use -g lazygit@latest \
	&& rtx use -g bat@latest \
	&& rtx use -g golang@latest


################################################################################
# neovim setup
################################################################################

RUN nvim=/root/.local/share/rtx/installs/neovim/nightly/bin/nvim \
# source $HOME/.zshrc \
	&& $nvim --headless "Lazy sync" +"sleep 30" +q \
	# Install Coq dependencies
	&& $nvim --headless "COQDeps" +"sleep 30" +q


################################################################################
# oh my zsh setup
################################################################################

RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# copy pre-oh-my-zsh contents to .zshrc
# delete .zshrc and replace with pre-oh-my-zsh contents
RUN rm $HOME/.zshrc \
	&& mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc 

# install powerlevel10k
RUN git clone --depth=1 \
	https://github.com/romkatv/powerlevel10k.git \
	${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


################################################################################
# misc setup
################################################################################

# Install lf terminal file manager
RUN env CGO_ENABLED=0 $HOME/.local/share/rtx/installs/go/latest/go/bin/go install -ldflags="-s -w" github.com/gokcehan/lf@latest

# RUN echo "export PATH=$HOME/.local/share/rtx/installs/go/1.20.5/packages/bin:$PATH" >> $HOME/.zshrc

# RUN source $HOME/.zshrc \
# 	&& go=$HOME/.local/share/rtx/installs/go/1.20.5/go/bin/go
# 	# && echo '\nexport PATH="$($go env GOPATH)/bin:$PATH"' >> $HOME/.zshrc


################################################################################
# potential packages (terminal and gui)
################################################################################

RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# RUN go install github.com/asciimoo/wuzz@latest
# RUN go install github.com/charmbracelet/bubbletea@latest
# RUN go install github.com/charmbracelet/glow@latest
# RUN cargo binstall projectable -y
# RUN cargo binstall bottom -y
# RUN cargo binstall ast-grep -y
# Something to handle bitwarden
# Task switcher
