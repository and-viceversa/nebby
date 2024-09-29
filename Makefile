all: setup env nebby tools

SHELL := /bin/bash
OS_NAME := $(shell uname -s | tr A-Z a-z)
export PATH = $(shell echo $$PATH:$$HOME/miniconda3/bin)
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
BREW := miniconda geoipupdate
APT := pkg-config coreutils geoipupdate curl sq gcc-multilib zsh
TOOLS := gitfive_temporary maigret ghunt subfinder alterx httpx dnsx naabu katana cloudlist trufflehog noseyparker fingerprintx lemmeknow awsrecon ares photon quidam blackbird sn0int dnstwist

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

.PHONY: install_prerequisites
install_prerequisites: checkos
	# Install prerequisites
	@if [ $(OS_NAME) == "darwin" ] && ! [ command -v brew &> /dev/null ]; then \
		NONINTERACTIVE=-1 $(SHELL) -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		brew install -q $(BREW); \
		conda init --all; \
	elif [ $(OS_NAME) == "darwin" ]; then \
		brew install -q $(BREW); \
		conda init --all; \
	elif [ $(OS_NAME) == "linux" ] && ! [ -x $$HOME/miniconda3/bin/conda ]; then \
		mkdir -p $$HOME/miniconda3; \
		curl -L -o $$HOME/miniconda3/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh; \
		bash $$HOME/miniconda3/miniconda.sh -b -u -p $$HOME/miniconda3; \
		rm $$HOME/miniconda3/miniconda.sh; \
		$$HOME/miniconda3/bin/conda init --all; \
		sudo add-apt-repository -y ppa:maxmind/ppa; \
		sudo apt -q -y install $(APT); \
	else \
		sudo add-apt-repository -y ppa:maxmind/ppa; \
		sudo apt -q -y install $(APT); \
	fi

.PHONY: update_packages
update_packages: checkos install_prerequisites
	# Update packages
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew update && brew upgrade; \
	else \
		sudo apt -q -y update && sudo apt -q -y upgrade; \
	fi
	@$(CONDA_ACTIVATE) base; \
	conda update -q -y conda; \
	conda update -q -y -n base conda

.PHONY: env
env: uninstall create

.PHONY: uninstall
uninstall:
	# Remove the old environment
	@-$(CONDA_ACTIVATE) nebby; \
	pipx uninstall-all
	@-$(CONDA_ACTIVATE) base; \
	conda env remove -y -q -n nebby
	@rm -rf ./clones
	@rm -rf ./build
	@rm -rf ./dist
	@rm -rf ./nebby.egg-info

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
	pip uninstall -q -y nebby; \
	python -m build &> /dev/null; \
	pip install -q ./dist/nebby-0.0.1-py3-none-any.whl

.PHONY: tools
tools: $(TOOLS)

# TODO: Return to the canonical install instructions once this gets fixed https://github.com/mxrch/GitFive/issues/51
.PHONY: gitfive_canonical
gitfive_canonical:
	# Install GitFive
	@$(CONDA_ACTIVATE) nebby; \
	pipx ensurepath --force
	@$(CONDA_ACTIVATE) nebby; \
	pipx install gitfive --force

.PHONY: gitfive_temporary
gitfive_temporary:
	# Install GitFive
	@$(CONDA_ACTIVATE) nebby; \
	cd clones; \
	rm -rf GitFive; \
	git clone -q https://github.com/mxrch/GitFive.git; \
	cd GitFive; \
	if [ $(OS_NAME) == "darwin" ]; then \
		sed -i '' -e 's/0.20.5/0.25.1/g' requirements.txt; \
	else \
		sed -i 's/0.20.5/0.25.1/g' requirements.txt; \
	fi; \
	pip -q install .
	@rm -rf ./clones/GitFive

.PHONY: ghunt
ghunt:
	# Install ghunt
	@$(CONDA_ACTIVATE) nebby; \
	pipx ensurepath --force
	@$(CONDA_ACTIVATE) nebby; \
	pipx install ghunt --force; \

.PHONY: maigret
maigret:
	# Install maigret
	@$(CONDA_ACTIVATE) nebby; \
	cd clones; \
	rm -rf maigret; \
	git clone -q https://github.com/soxoj/maigret.git; \
	cd maigret; \
	pip install -q .
	@rm -rf ./clones/maigret

.PHONY: subfinder
subfinder:
	# Install Subfinder
	@$(CONDA_ACTIVATE) nebby ; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

.PHONY: alterx
alterx:
	# Install AlterX
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install github.com/projectdiscovery/alterx/cmd/alterx@latest

.PHONY: httpx
httpx:
	# Install httpx
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	rm $$CONDA_PREFIX/bin/httpx; \
	go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

.PHONY: dnsx
dnsx:
	# Install dnsx
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

.PHONY: naabu
naabu:
	# Install naabu
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

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
	go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest

.PHONY: trufflehog
trufflehog:
	# Install trufflehog
	@-$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	cd clones; \
	git clone -q https://github.com/trufflesecurity/trufflehog.git; \
	cd trufflehog; go install
	@rm -rf ./clones/trufflehog

.PHONY: noseyparker
noseyparker:
	# Install noseyparker
	@-if [ $(OS_NAME) == "darwin" ]; then \
		brew install noseyparker; \
	else \
		cd clones && mkdir -p noseyparker && cd noseyparker; \
		curl -L -O https://github.com/praetorian-inc/noseyparker/releases/download/v0.19.0/noseyparker-v0.19.0-x86_64-unknown-linux-gnu.tar.gz; \
		tar -xzf noseyparker-v0.19.0-x86_64-unknown-linux-gnu.tar.gz; \
		cp ./bin/noseyparker $$CONDA_PREFIX/bin/noseyparker; \
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
	cargo install lemmeknow --root $$CONDA_PREFIX

.PHONY: awsrecon
awsrecon:
	# Install awsrecon
	@$(CONDA_ACTIVATE) nebby; \
	export GOBIN=$$CONDA_PREFIX/bin; \
	go install -v github.com/hupe1980/awsrecon@latest

.PHONY: ares
ares:
	# Install ares
	@$(CONDA_ACTIVATE) nebby; \
	cargo install project_ares --root $$CONDA_PREFIX

.PHONY: photon
photon:
	# Install photon
	@$(CONDA_ACTIVATE) nebby; \
	cd ./clones; \
	git clone https://github.com/s0md3v/Photon.git; \
	cd Photon; \
	pip install -r requirements.txt

.PHONY: quidam
quidam:
	# Install quidam
	@$(CONDA_ACTIVATE) nebby; \
	cd ./clones; \
	git clone https://github.com/megadose/Quidam.git; \
	cd Quidam; \
	pip install -q .

.PHONY: blackbird
blackbird:
	# Install blackbird
	@$(CONDA_ACTIVATE) nebby; \
	cd ./clones; \
	git clone https://github.com/p1ngul1n0/blackbird.git; \
	cd blackbird; \
	pip install -q -r requirements.txt

.PHONY: sn0int
sn0int:
	# Install sn0int
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew install sn0int; \
	else \
		curl -sSf https://apt.vulns.xyz/kpcyrd.pgp | sq keyring filter -B --handle 64B13F7117D6E07D661BBCE0FE763A64F5E54FD6 | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null; \
		echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list; \
		sudo apt -q -y update; \
		sudo apt -q -y install sn0int; \
	fi

.PHONY: dnstwist
dnstwist:
	# Install dnstwist
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew install dnstwist; \
	else \
		sudo apt -q -y install dnstwist; \
	fi


.PHONY: delete
delete: uninstall
	# Deleting all nebby installs and clearing caches
	# Errors in this recipe can be safely ignored
	@-$(CONDA_ACTIVATE) nebby; \
	conda init --reverse --all; \
	conda clean -y -a &> /dev/null
	@rm -rf $$HOME/micromamba
	@rm -rf $$HOME/.conda
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew uninstall $(BREW); \
		brew uninstall noseyparker; \
		brew uninstall sn0int; \
		brew uninstall dnstwist; \
		brew autoremove -q; \
		brew cleanup -s --prune 0; \
	else \
		sudo apt -q -y remove $(APT); \
		sudo apt -q -y remove sn0int; \
		sudo apt -q -y remove dnstwist; \
		sudo apt -q -y autoremove; \
		rm -rf $$HOME/miniconda3; \
	fi

.PHONY: clean
clean: delete setup env nebby tools
