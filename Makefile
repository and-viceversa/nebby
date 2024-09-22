all: setup micromamba nebby tools

SHELL := /bin/bash
OS_NAME := $(shell uname -s | tr A-Z a-z)
MAMBA_ACTIVATE=source $$MAMBA_ROOT_PREFIX/etc/profile.d/micromamba.sh ; micromamba activate ; micromamba activate
export GOBIN := $(shell echo $$MAMBA_ROOT_PREFIX/envs/nebby/bin)
BREW := micromamba wget geoipupdate
APT := wget pkg-config coreutils geoipupdate curl sq
TOOLS := gitfive_temporary maigret ghunt subfinder alterx httpx dnsx naabu katana cloudlist trufflehog noseyparker fingerprintx lemmeknow awsrecon ares photon quidam blackbird sn0int dnstwist

.PHONY: setup
setup: checkos install_prerequisites update_packages

.PHONY: checkos
checkos:
	# Operating system checks
	@if [ $(OS_NAME) == "linux" -o $(OS_NAME) == "darwin" ]; then \
		echo "We're running $(OS_NAME)"; \
	else \
		echo "This OS doesn't support nebby"; \
		exit; \
	fi

.PHONY: install_prerequisites
install_prerequisites: checkos
	# Install prerequisites
	@if [ $(OS_NAME) == "darwin" -a ! command -v brew &> /dev/null ]; then \
		NONINTERACTIVE=-1 $(SHELL) -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	elif [ $(OS_NAME) == "darwin" ]; then \
		brew install $(BREW); \
	else \
		sudo add-apt-repository ppa:maxmind/ppa; \
		sudo apt install $(APT) ; \
		$(SHELL) <(curl -L micro.mamba.pm/install.sh); \
	fi
	micromamba shell init -s bash --root-prefix=$$HOME/micromamba 1> /dev/null
	micromamba shell init -s zsh --root-prefix=$$HOME/micromamba 1> /dev/null
	micromamba shell init -s fish --root-prefix=$$HOME/micromamba 1> /dev/null

.PHONY: update_packages
update_packages: checkos install_prerequisites
	# Update packages
	@if [ $(OS_NAME) == "darwin" ]; then \
  		brew update && brew upgrade; \
  	else \
  		sudo apt -y update && sudo apt -y upgrade; \
  	fi
	micromamba self-update -c conda-forge anaconda 1> /dev/null

.PHONY: micromamba
micromamba: uninstall create

.PHONY: uninstall
uninstall:
	# Remove the old environment
	# If this command throws "No Prefix found at:" errors, you can safely ignore them
	@-pipx uninstall-all
	@-micromamba env remove -y -q -n nebby
	@rm -rf ./clones
	@rm -rf ./build
	@rm -rf ./dist
	@rm -rf ./nebby.egg-info

.PHONY: create
create: uninstall
	# Create the new environment
	@micromamba create -y -f environment.yaml
	@mkdir clones

.PHONY: nebby
nebby:
	# Build Nebby
	@$(MAMBA_ACTIVATE) nebby ; \
	pip uninstall -y nebby; \
	python -m build ; \
	pip install ./dist/nebby-0.0.1-py3-none-any.whl

.PHONY: tools
tools: $(TOOLS)

# TODO: Return to the canonical install instructions once this gets fixed https://github.com/mxrch/GitFive/issues/51
.PHONY: gitfive_canonical
gitfive_canonical:
	# Install GitFive
	@$(MAMBA_ACTIVATE) nebby ; \
	pipx ensurepath
	@$(MAMBA_ACTIVATE) nebby ; \
	pipx install gitfive --force

.PHONY: gitfive_temporary
gitfive_temporary:
	# Install GitFive
	@$(MAMBA_ACTIVATE) nebby; \
	cd clones; \
	rm -rf GitFive; \
	git clone https://github.com/mxrch/GitFive.git; \
	cd GitFive; \
	if [ $(OS_NAME) == "darwin" ]; then \
		sed -i '' -e 's/0.20.5/0.25.1/g' requirements.txt; \
	else \
		sed -i 's/0.20.5/0.25.1/g' requirements.txt; \
	fi; \
	pip install .

.PHONY: ghunt
ghunt:
	# Install ghunt
	@$(MAMBA_ACTIVATE) nebby ; \
	pipx ensurepath
	@$(MAMBA_ACTIVATE) nebby ; \
	pipx install ghunt --force; \
	pipx ensurepath

.PHONY: maigret
maigret:
	# Install maigret
	@$(MAMBA_ACTIVATE) nebby; \
	cd clones; \
	rm -rf maigret; \
	git clone https://github.com/soxoj/maigret.git; \
	cd maigret; \
	pip install .

.PHONY: subfinder
subfinder:
	# Install Subfinder
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

.PHONY: alterx
alterx:
	# Install AlterX
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install github.com/projectdiscovery/alterx/cmd/alterx@latest

.PHONY: httpx
httpx:
	# Install httpx
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

.PHONY: dnsx
dnsx:
	# Install dnsx
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

.PHONY: naabu
naabu:
	# Install naabu
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

.PHONY: katana
katana:
	# Install katana
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install github.com/projectdiscovery/katana/cmd/katana@latest

.PHONY: cloudlist
cloudlist:
	# Install cloudlist
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest

.PHONY: trufflehog
trufflehog:
	# Install trufflehog
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	cd clones; \
	git clone https://github.com/trufflesecurity/trufflehog.git; \
	cd trufflehog; go install

.PHONY: noseyparker
noseyparker:
	# Install noseyparker
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew install noseyparker; \
	else \
		export CARGO_TARGET_DIR=$(GOBIN); \
		cd clones; \
		rm -rf noseyparker; \
		git clone https://github.com/praetorian-inc/noseyparker.git; \
		cd noseyparker; \
		rm -rf release && ./scripts/create-release.zsh; \
		cp ./target/release/noseyparker-cli $(shell echo $(GOBIN)); \
	fi

.PHONY: fingerprintx
fingerprintx:
	# Install fingerprintx
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install github.com/praetorian-inc/fingerprintx/cmd/fingerprintx@latest

.PHONY: lemmeknow
lemmeknow:
	# Install lemmeknow
	@$(MAMBA_ACTIVATE) nebby ; \
	export CARGO_TARGET_DIR=$(GOBIN); \
	cargo install lemmeknow; \
	cp ~/.cargo/bin/lemmeknow $(shell echo $(GOBIN)); \
	rm ~/.cargo/bin/lemmeknow

.PHONY: awsrecon
awsrecon:
	# Install awsrecon
	@$(MAMBA_ACTIVATE) nebby ; \
	export GOBIN=$(GOBIN); \
	go install -v github.com/hupe1980/awsrecon@latest

.PHONY: ares
ares:
	# Install ares
	@$(MAMBA_ACTIVATE) nebby ; \
	export CARGO_TARGET_DIR=$(GOBIN); \
	cargo install project_ares; \
	cp ~/.cargo/bin/ares $(shell echo $(GOBIN)); \
	rm ~/.cargo/bin/ares

.PHONY: photon
photon:
	# Install photon
	@$(MAMBA_ACTIVATE) nebby ; \
	cd ./clones; \
	git clone https://github.com/s0md3v/Photon.git; \
	cd Photon; \
	pip install -r requirements.txt

.PHONY: quidam
quidam:
	# Install quidam
	@$(MAMBA_ACTIVATE) nebby ; \
	cd ./clones; \
	git clone https://github.com/megadose/Quidam.git; \
	cd Quidam; \
	pip install .

.PHONY: blackbird
blackbird:
	# Install blackbird
	@$(MAMBA_ACTIVATE) nebby ; \
	cd ./clones; \
	git clone https://github.com/p1ngul1n0/blackbird.git; \
	cd blackbird; \
	pip install -r requirements.txt

.PHONY: sn0int
sn0int:
	# Install sn0int
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew install sn0int; \
	else \
		curl -sSf https://apt.vulns.sexy/kpcyrd.pgp | sq keyring filter -B --handle 64B13F7117D6E07D661BBCE0FE763A64F5E54FD6 | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg > /dev/null; \
		echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list; \
		apt -y update; \
		apt -y install sn0int; \
	fi

.PHONY: dnstwist
dnstwist:
	# Install dnstwist
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew install dnstwist; \
	else \
		sudo apt install dnstwist; \
	fi


.PHONY: delete
delete: uninstall
	# Deleting all nebby installs and clearing caches
	# Errors in this recipe can be safely ignored
	@-micromamba clean -y -a &> /dev/null
	@-micromamba shell deinit bash
	@-micromamba shell deinit zsh
	@-micromamba shell deinit fish
	@-rm -rf $$HOME/micromamba
	@if [ $(OS_NAME) == "darwin" ]; then \
		brew uninstall $(BREW); \
		brew uninstall noseyparker; \
		brew uninstall sn0int; \
		brew uninstall dnstwist; \
		brew autoremove -q; \
		brew cleanup -s --prune 0; \
	else \
		sudo apt uninstall $(APT); \
		sudo apt uninstall sn0int; \
	fi
	@which micromamba | xargs rm