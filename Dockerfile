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
	lzma \
	libffi-dev \
	libjpeg-dev \
	zlib1g-dev \
	locales \
	zsh

RUN locale-gen en_US.UTF-8

RUN pip install ranger-fm

# install FZF
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
	~/.fzf/install

# install pyenv
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv

# install neovim python packages
RUN pip install pynvim

################################################################################
# chezmoi setup
################################################################################

RUN zsh -c "$(curl -fsLS get.chezmoi.io)" \
	-- init \
	--apply QuestionableAntics


################################################################################
# asdf setup
################################################################################

# install asdf
RUN git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf

RUN asdf=$HOME/.asdf/bin/asdf \
	&& $asdf plugin add neovim \
	&& $asdf plugin add dotnet-core https://github.com/emersonsoares/asdf-dotnet-core.git \
	# && $asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
	&& $asdf plugin add python \
	&& $asdf plugin add lazydocker https://github.com/comdotlinux/asdf-lazydocker.git \
	&& $asdf plugin add lazygit https://github.com/nklmilojevic/asdf-lazygit.git \
	&& $asdf plugin add bat \
	&& $asdf install neovim nightly \
	&& $asdf install dotnet-core 7.0.304 \
	# && $asdf install nodejs 20.3.0 \
	&& $asdf install python 3.9.12 \
	&& $asdf install lazydocker 0.20.0 \
	&& $asdf install lazygit latest \
	&& $asdf install bat latest \
	&& $asdf global neovim nightly \
	&& $asdf global dotnet-core 7.0.304 \
	# && $asdf global nodejs lts \
	&& $asdf global python 3.9.12 \
	&& $asdf global lazydocker 0.20.0 \
	&& $asdf global lazygit latest \
	&& $asdf global bat latest

RUN echo '\n. $HOME/.asdf/asdf.sh' >> $HOME/.zshrc
RUN echo '\nexport PATH="$HOME/.asdf/bin:$PATH"' >> $HOME/.zshrc


################################################################################
# oh my zsh setup
################################################################################

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# RUN rm $HOME/.zshrc
# copy pre-oh-my-zsh contents to .zshrc
RUN cat $HOME/.zshrc.pre-oh-my-zsh >> $HOME/.zshrc

# RUN mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc

# install powerlevel10k
# RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# RUN echo 'source ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
# RUN echo 'source $HOME/.oh-my-zsh/custom/themes/powerlevel10k' >> ~/.zshrc
# RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# RUN echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc


################################################################################
# neovim setup
################################################################################

# First time is to install plugins
RUN /root/.asdf/shims/nvim --headless "Lazy sync" +q

# Second time is to install treesitter parsers
RUN /root/.asdf/shims/nvim --headless +q


################################################################################
# misc
################################################################################

RUN curl -sSL https://install.python-poetry.org | python3 -
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& ./aws/install
	# && sudo ./aws/install

# make zsh default shell
RUN chsh -s $(which zsh)
CMD [ "zsh" ]
