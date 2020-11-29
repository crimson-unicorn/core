parsers-version=master
analyzer-version=master
modeler-version=master

prepare_parsers:
	mkdir -p build
	cd build && git clone --single-branch -b $(parsers-version) https://github.com/crimson-unicorn/parsers.git

prepare_analyzer:
	mkdir -p build
	cd build && git clone --single-branch -b $(analyzer-version) https://github.com/crimson-unicorn/analyzer.git
	cd build/analyzer && make sb

prepare_modeler:
	mkdir -p build
	cd build && git clone --single-branch -b $(modeler-version) https://github.com/crimson-unicorn/modeler.git

prepare_output:
	mkdir -p output

prepare: prepare_parsers prepare_analyzer prepare_modeler prepare_output

define dataverse_download
	wget --retry-connrefused --waitretry=5 --read-timeout=30 --tries=50 --no-dns-cache https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O data/tmp.tar.gz
	cd data && tar -xzf tmp.tar.gz
	rm -f data/tmp.tar.gz
endef

download_streamspot:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/83KYJY/JVJXX5)

run_toy:
	cd build/parsers && make toy
	cd build/analyzer && make toy
	cd build/modeler && make toy

toy: prepare download_streamspot run_toy

clean:
	rm -rf build
	rm -rf data
