all: setup env nebby tools

SHELL := /bin/bash
OS_NAME := $(shell uname -s | tr A-Z a-z)
export PATH = $(shell echo $$PATH:$$HOME/miniforge/bin:/opt/homebrew/bin:/usr/local/bin)
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
CONDA_BIN := $(shell echo "$$CONDA_PREFIX/bin")
PWD := $(shell pwd)
BREW := miniforge geoipupdate jpeg zlib sn0int
APT := pkg-config coreutils geoipupdate curl sq g++ gcc-multilib zsh chromium-chromedriver
TOOLS := gitfive ghunt maigret subfinder alterx httpx dnsx naabu katana cloudlist trufflehog noseyparker fingerprintx lemmeknow awsrecon photon quidam blackbird sn0int dnstwist mailcat linkook snscrape sherlock holehe onionsearch nqntnqnqmb toutatis ignorant crosslinked masto pywhat xeuledoc porch-pirate

.PHONY: setup
setup: checkos install_prerequisites update_packages

.PHONY: checkos
checkos:
	# Operating system checks
	@if [ $(OS_NAME) == "linux" ] || [ $(OS_NAME) == "darwin" ]; then \
		echo "We're running $(OS_NAME)"; \
	else \
		echo "This OS doesn't support nebby"; \
		exit; \
	fi

.PHONY: install_xcode
install_xcode:
	@-if [ $(OS_NAME) == "darwin" ]; then \
		echo "# Install xcode"; \
		xcode-select --install; \
	else \
		:; \
	fi

.PHONY: install_brew
install_brew:
	@if [ $(OS_NAME) == "darwin" ] && [ -z $$(command -v brew) ]; then \
		echo "# Install homebrew"; \
		sudo true; \
		export NONINTERACTIVE=-1; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash; \
		echo >> $$HOME/.zprofile; \
		echo >> $$HOME/.bashrc; \
		if [ $$(uname -m) == "arm64" ]; then \
			echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> $$HOME/.zprofile; \
			echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> $$HOME/.bashrc; \
			eval "$$(/opt/homebrew/bin/brew shellenv)"; \
		elif [ $$(uname -m) == "x86_64" ]; then \
			echo 'eval "$$(/usr/local/bin/brew shellenv)"' >> $$HOME/.zprofile; \
			echo 'eval "$$(/usr/local/bin/brew shellenv)"' >> $$HOME/.bashrc; \
			eval "$$(/usr/local/bin/brew shellenv)"; \
		else \
			:; \
		fi; \
		brew analytics off; \
	elif [ $(OS_NAME) == "darwin" ] && [ -n $$(command -v brew) ]; then \
		echo "# Homebrew already installed"; \
	else \
		:; \
	fi

.PHONY: install_brew_packages
install_brew_packages:
	@if [ $(OS_NAME) == "darwin" ]; then \
		echo "# Install brew packages"; \
		brew install -q $(BREW); \
		conda init -q --all; \
	else \
		:; \
	fi

.PHONY: install_miniforge_linux
install_miniforge_linux:
	@if [ $(OS_NAME) == "linux" ] && ! [ -x $$HOME/miniforge/bin/conda ]; then \
		@echo "# Install miniforge prerequisites"; \
		mkdir -p $$HOME/miniforge; \
		curl -L -o $$HOME/miniforge/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh; \
		bash $$HOME/miniforge/miniforge.sh -b -u -p $$HOME/miniforge; \
		rm $$HOME/miniforge/miniforge.sh; \
		$$HOME/miniforge/bin/conda init -q --all; \
	else \
		:; \
	fi
	@-$(CONDA_ACTIVATE) base; \
	conda config -q --add channels conda-forge

.PHONY: install_apt_packages_linux
install_apt_packages_linux:
	@if [ $(OS_NAME) == "linux" ]; then \
		echo "# Install apt packages"; \
		sudo add-apt-repository -y ppa:maxmind/ppa; \
		sudo apt -q -y install $(APT); \
	fi

.PHONY: install_prerequisites
install_prerequisites: checkos install_xcode install_brew install_brew_packages install_miniforge_linux install_apt_packages_linux

.PHONY: update_packages
update_packages: checkos install_prerequisites
	# Update packages
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew update && brew upgrade; \
	else \
		sudo apt -q -y update && sudo apt -q -y upgrade; \
	fi
	@$(CONDA_ACTIVATE) base; \
	conda update -q -y -n base -c conda-forge conda

.PHONY: env
env: uninstall create

.PHONY: uninstall
uninstall:
	# Remove the old environment
	# Errors in this recipe can be safely ignored
	@-$(CONDA_ACTIVATE) nebby; \
	uv cache -q clean; \
	go clean -cache; \
	rm -rf $$HOME/.cargo
	@-$(CONDA_ACTIVATE) base; \
	conda env remove -q -y -n nebby &> /dev/null
	@rm -rf ./clones
	@rm -rf ./build
	@rm -rf ./dist
	@rm -rf ./nebby.egg-info
	@rm -rf ./.venv

.PHONY: create
create: uninstall
	# Create the new environment
	@$(CONDA_ACTIVATE) base; \
	conda env create -q --file=environment.yaml; \
	mkdir -p clones

.PHONY: nebby
nebby:
	# Build nebby
	@$(CONDA_ACTIVATE) nebby; \
	uv tool uninstall -q nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv build -q; \
	uv tool install -q .

.PHONY: tools
tools: $(TOOLS)

 .PHONY: gitfive
 gitfive:
	# Install GitFive
	@$(CONDA_ACTIVATE) nebby; \
	rm -rf ./clones/gitfive; \
	git clone -q https://github.com/mxrch/gitfive ./clones/gitfive
	@uv build -q ./clones/gitfive
	@export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q ./clones/gitfive
	@rm -rf ./clones/gitfive

.PHONY: ghunt
ghunt:
	# Install ghunt
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q ghunt


.PHONY: maigret
maigret:
	# Install maigret
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q maigret

.PHONY: subfinder
subfinder:
	# Install Subfinder
	@$(CONDA_ACTIVATE) nebby ; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

.PHONY: alterx
alterx:
	# Install alterx
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/alterx/cmd/alterx@latest

.PHONY: httpx
httpx:
	# Install httpx
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/httpx/cmd/httpx@latest

.PHONY: dnsx
dnsx:
	# Install dnsx
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

.PHONY: naabu
naabu:
	# Install naabu
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

.PHONY: katana
katana:
	# Install katana
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/katana/cmd/katana@latest

.PHONY: cloudlist
cloudlist:
	# Install cloudlist
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest

.PHONY: trufflehog
trufflehog:
	# Install trufflehog
	@-$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	rm -rf ./clones/trufflehog; \
	git clone -q https://github.com/trufflesecurity/trufflehog.git ./clones/trufflehog; \
	cd ./clones/trufflehog; \
	go install
	@rm -rf ./clones/trufflehog

.PHONY: noseyparker
noseyparker:
	# Install noseyparker
	@-if [ $(OS_NAME) == "darwin" ]; then \
		$(CONDA_ACTIVATE) nebby; \
		cd clones && mkdir -p noseyparker && cd noseyparker; \
		curl -L -O -s https://github.com/praetorian-inc/noseyparker/releases/download/v0.24.0/noseyparker-v0.24.0-x86_64-apple-darwin.tar.gz; \
		tar -xzf noseyparker-v0.24.0-x86_64-apple-darwin.tar.gz; \
		cp ./bin/noseyparker $$CONDA_PREFIX/bin/noseyparker; \
		rm -rf ./clones/noseyparker; \
	else \
		$(CONDA_ACTIVATE) nebby; \
		cd clones && mkdir -p noseyparker && cd noseyparker; \
		curl -L -O -s https://github.com/praetorian-inc/noseyparker/releases/download/v0.24.0/noseyparker-v0.24.0-x86_64-unknown-linux-gnu.tar.gz; \
		tar -xzf noseyparker-v0.24.0-x86_64-unknown-linux-gnu.tar.gz; \
		cp ./bin/noseyparker $$CONDA_PREFIX/bin/noseyparker; \
		rm -rf ./clones/noseyparker; \
	fi

.PHONY: fingerprintx
fingerprintx:
	# Install fingerprintx
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/praetorian-inc/fingerprintx/cmd/fingerprintx@latest

.PHONY: lemmeknow
lemmeknow:
	# Install lemmeknow
	@$(CONDA_ACTIVATE) nebby; \
	cargo install -q lemmeknow --root $$CONDA_PREFIX

.PHONY: awsrecon
awsrecon:
	# Install awsrecon
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/hupe1980/awsrecon@latest

# NOTE: Omitted from install. There are dependency errors in the rust build chain
.PHONY: ares
ares:
	# Install ares
	@$(CONDA_ACTIVATE) nebby; \
	cargo install -q project_ares --root $$CONDA_PREFIX

.PHONY: photon
photon:
	# Install photon
	@$(CONDA_ACTIVATE) nebby; \
	git clone -q https://github.com/s0md3v/Photon.git ./clones/Photon; \
	uv pip install -q -r ./clones/Photon/requirements.txt

.PHONY: quidam
quidam:
	# Install quidam
	@$(CONDA_ACTIVATE) nebby; \
	git clone -q https://github.com/megadose/Quidam.git ./clones/Quidam; \
	uv pip install -q ./clones/Quidam

.PHONY: blackbird
blackbird:
	# Install blackbird
	@$(CONDA_ACTIVATE) nebby; \
	git clone -q https://github.com/p1ngul1n0/blackbird.git ./clones/blackbird; \
	uv pip install -q -r ./clones/blackbird/requirements.txt

.PHONY: sn0int
sn0int:
	# Install sn0int
	@if [ $(OS_NAME) == "darwin" ]; then \
		:; \
	else \
		curl -sSf https://apt.vulns.xyz/kpcyrd.pgp | sq keyring filter -B --handle 64B13F7117D6E07D661BBCE0FE763A64F5E54FD6 | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null; \
		echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list; \
		sudo apt -q -y update; \
		sudo apt -q -y install sn0int; \
	fi

.PHONY: dnstwist
dnstwist:
	# Install dnstwist
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q dnstwist[full]

.PHONY: mailcat
mailcat:
	# Install mailcat
	@$(CONDA_ACTIVATE) nebby; \
	git clone -q https://github.com/sharsil/mailcat.git ./clones/mailcat; \
	uv pip install -q -r ./clones/mailcat/requirements.txt

.PHONY: linkook
linkook:
	# Install linkook
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q linkook

.PHONY: snscrape
snscrape:
	# Install snscrape
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q snscrape

.PHONY: sherlock
sherlock:
	# Install sherlock
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q sherlock-project

.PHONY: holehe
holehe:
	# Install holehe
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q holehe

.PHONY: onionsearch
onionsearch:
	# Install onionsearch
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q onionsearch

.PHONY: nqntnqnqmb
nqntnqnqmb:
	# Install nqntnqnqmb
	@$(CONDA_ACTIVATE) nebby; \
	git clone -q https://github.com/megadose/nqntnqnqmb ./clones/nqntnqnqmb; \
	uv pip install -q ./clones/nqntnqnqmb

.PHONY: toutatis
toutatis:
	# Install toutatis
	@$(CONDA_ACTIVATE) nebby; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q toutatis

.PHONY: ignorant
ignorant:
	# Install ignorant
	@$(CONDA_ACTIVATE) nebby; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q git+https://github.com/megadose/ignorant

.PHONY: crosslinked
crosslinked:
	# Install crosslinked
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q crosslinked

.PHONY: masto
masto:
	# Install masto
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q masto

.PHONY: pywhat
pywhat:
	# Install pywhat
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q pywhat[optimize]

.PHONY: xeuledoc
xeuledoc:
	# Install xeuledoc
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q xeuledoc

.PHONY: porch-pirate
porch-pirate:
	# Install porch-pirate
	@$(CONDA_ACTIVATE) nebby; \
	export XDG_BIN_HOME=""$(CONDA_BIN)""; \
	export UV_INSTALL_DIR=""$(PWD)""; \
	uv tool install -q porch-pirate

.PHONY: delete
delete: uninstall
	# Deleting all nebby installs and clearing caches
	# Errors in this recipe can be safely ignored
	@-$(CONDA_ACTIVATE) base; \
	conda init -q --reverse --all &> /dev/null; \
	conda clean -q -y -a &> /dev/null; \
	rm -rf $$HOME/.conda
	@-if [ $(OS_NAME) == "darwin" ]; then \
		brew uninstall -q --cask miniforge --force &> /dev/null; \
		brew uninstall -q $(BREW) &> /dev/null; \
		brew autoremove -q &> /dev/null; \
		brew cleanup -q -s --prune=all &> /dev/null; \
	else \
		sudo apt -q -y remove $(APT); \
		sudo apt -q -y autoremove; \
		rm -rf $$HOME/miniforge; \
	fi

.PHONY: clean
clean: delete setup create nebby tools
