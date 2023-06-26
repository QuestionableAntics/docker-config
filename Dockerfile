# syntax=docker/dockerfile:1
from ubuntu:latest


################################################################################
# install packages
################################################################################

RUN apt-get update \
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

# not default in ubuntu and required by everything
RUN locale-gen en_US.UTF-8

# install ranger and dependencies
RUN pip install ranger-fm
RUN pip install pynvim

# install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
	~/.fzf/install

# setup dotfiles
RUN zsh -c "$(curl -fsLS get.chezmoi.io)" \
	-- init \
	--apply QuestionableAntics

# install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& ./aws/install

# install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -


################################################################################
# asdf setup
################################################################################

# install asdf
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf

RUN asdf=$HOME/.asdf/bin/asdf \
	&& $asdf plugin add neovim \
	&& $asdf plugin add dotnet-core https://github.com/emersonsoares/asdf-dotnet-core.git \
	&& $asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
	&& $asdf plugin add python \
	&& $asdf plugin add lazydocker https://github.com/comdotlinux/asdf-lazydocker.git \
	&& $asdf plugin add lazygit https://github.com/nklmilojevic/asdf-lazygit.git \
	&& $asdf plugin add bat \
	&& $asdf plugin add golang https://github.com/kennyp/asdf-golang.git \
	&& $asdf install neovim nightly \
	&& $asdf install dotnet-core 7.0.304 \
	&& $asdf install python 3.9.12 \
	&& $asdf install lazydocker 0.20.0 \
	&& $asdf install lazygit latest \
	&& $asdf install bat latest \
	&& $asdf install golang 1.20.5 \
	&& $asdf global neovim nightly \
	&& $asdf global dotnet-core 7.0.304 \
	&& $asdf global python 3.9.12 \
	&& $asdf global lazydocker 0.20.0 \
	&& $asdf global lazygit latest \
	&& $asdf global bat latest \
	&& $asdf global golang 1.20.5

RUN echo 'alias="asdf/root/.asdf/bin/asdf"' >> $HOME/.zshrc
RUN echo '\n. $HOME/.asdf/asdf.sh' >> $HOME/.zshrc
RUN echo '\nexport PATH="$HOME/.asdf/bin:$PATH"' >> $HOME/.zshrc

# This does not work if included above
# Seems to be due to the install needing asdf to be in a certain location
RUN zsh -c $HOME/.asdf/bin/asdf install nodejs 20.3.1
RUN zsh -c $HOME/.asdf/bin/asdf global nodejs 20.3.1


################################################################################
# oh my zsh setup
################################################################################

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# copy pre-oh-my-zsh contents to .zshrc
RUN cat $HOME/.zshrc.pre-oh-my-zsh >> $HOME/.zshrc \
	&& rm $HOME/.zshrc.pre-oh-my-zsh

# install powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


################################################################################
# neovim setup
################################################################################

# First time is to install plugins
RUN /root/.asdf/shims/nvim --headless "Lazy sync" +"sleep 30" +q

# Install Coq dependencies
RUN /root/.asdf/shims/nvim --headless "COQDeps" +"sleep 30" +q

# Second time is to install treesitter parsers
RUN /root/.asdf/shims/nvim --headless +q


################################################################################
# misc
################################################################################

# override fd with fdfind
RUN ln -s $(which fdfind) ~/.local/bin/fd
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc

# make zsh default shell
RUN chsh -s $(which zsh)
CMD [ "zsh" ]
