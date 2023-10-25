# syntax=docker/dockerfile:1
from ubuntu:latest


################################################################################
# install packages
################################################################################

RUN apt-get update -y \
	&& apt-get install -y \
	apt-utils \
	build-essential \
	bzip2 \
	cmake \
	curl \
	git \
    gzip \
	libbz2-dev \
	libncurses5-dev \
	libncursesw5-dev \
	libffi-dev \
	libjpeg-dev \
	liblzma-dev \
	libreadline8 \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	locales \
	lzma \
    nginx \
	openssl \
	pkg-config \
	python3-pip \
	sqlite3 \
    supervisor \
	unzip \
	wget \
	yasm \
	zlib1g-dev \
	zsh

# make zsh default shell
RUN chsh -s $(which zsh)
CMD [ "zsh" ]
SHELL ["/bin/zsh", "-c"]

# install rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# not default in ubuntu and required by everything
RUN locale-gen en_US.UTF-8

RUN pip install pynvim aider-chat

# setup dotfiles
RUN zsh -c "$(curl -fsLS get.chezmoi.io)" \
	-- init \
	--apply QuestionableAntics


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
	&& rtx use -g golang@latest \
	&& rtx use -g ripgrep@latest \
	&& rtx use -g fzf@latest \
	&& rtx use -g fd@latest \
	&& rtx use -g poetry@latest \
	&& rtx use -g awscli@latest \
	&& rtx use -g lua@latest \
	&& rtx use -g delta@latest



################################################################################
# neovim setup
################################################################################

RUN eval "$(rtx env -s zsh)" \
	# && nvim --headless "Lazy sync" +"sleep 20" +q
	&& nvim --headless "Lazy! sync" +qa


################################################################################
# oh my zsh setup
################################################################################

RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
	&& git clone --depth=1 \
		https://github.com/zsh-users/zsh-syntax-highlighting.git \
		$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
	# copy pre-oh-my-zsh contents to .zshrc
	# delete .zshrc and replace with pre-oh-my-zsh contents
	&& rm $HOME/.zshrc \
	&& mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc \
	# install powerlevel10k
	&& git clone --depth=1 \
		https://github.com/romkatv/powerlevel10k.git \
		${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


################################################################################
# misc setup
################################################################################

# Install lf terminal file manager
RUN eval "$(rtx env -s zsh)" \
	&& env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest

RUN eval "$(rtx env -s zsh)" \
	&& npm install -g gitid

# Set shell to zsh (not respected in neovim otherwise)
RUN echo "export SHELL=$(which zsh)" >> $HOME/.zshrc

# # https://stackoverflow.com/questions/72978485/git-submodule-update-failed-with-fatal-detected-dubious-ownership-in-repositor
# RUN git config --global --add safe.directory '*'

# https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container
# RUN useradd --create-home --shell /bin/zsh ubuntu
# RUN usermod -aG sudo ubuntu
# RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# RUN echo 'ubuntu:ubuntu' | chpasswd
# USER ubuntu
# WORKDIR /home/ubuntu


################################################################################
# potential packages (terminal and gui)
################################################################################

# RUN go install github.com/charmbracelet/bubbletea@latest
# RUN go install github.com/charmbracelet/glow@latest
# RUN cargo binstall projectable -y
# RUN cargo binstall bottom -y
# RUN cargo binstall ast-grep -y
# Something to handle bitwarden
# Task switcher
	# Raycast for mac
	# hopefully they update to support linux
# cargo install --git https://github.com/sxyazi/yazi.git
