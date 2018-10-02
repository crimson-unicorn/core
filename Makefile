parsers-version=master
graphchi-version=master
modeling-version=master

prepare_parsers:
	mkdir -p build
	cd build && git clone --single-branch -b $(parsers-version) https://github.com/crimson-unicorn/parsers

prepare_graphchi:
	mkdir -p build
	cd build && git clone --single-branch -b $(graphchi-version) https://github.com/crimson-unicorn/graphchi-cpp
	cd build/graphchi-cpp && make sdebug

prepare_modeling:
	mkdir -p build
	cd build && git clone --single-branch -b $(modeling-version)  https://github.com/crimson-unicorn/modeling

prepare_output:
	mkdir -p output

prepare: prepare_parsers prepare_graphchi prepare_modeling prepare_output

define dataverse_download
	wget https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O data/tmp.tar.gz
	cd data && tar -xzf tmp.tar.gz
	rm -f data/tmp.tar.gz
endef

download_wget:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/8GKEON/OFFMN3)
	$(call dataverse_download,10.7910/DVN/8GKEON/57BKKU)
	$(call dataverse_download,10.7910/DVN/8GKEON/YKHWW4)
	$(call dataverse_download,10.7910/DVN/8GKEON/AQLIIL)

download_streamspot:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/83KYJY/2MXIOX)
	$(call dataverse_download,10.7910/DVN/83KYJY/OGLWB4)
	$(call dataverse_download,10.7910/DVN/83KYJY/WYRXPD)
	$(call dataverse_download,10.7910/DVN/83KYJY/5ODRYF)
	$(call dataverse_download,10.7910/DVN/83KYJY/2EQZ4L)
	$(call dataverse_download,10.7910/DVN/83KYJY/WKXIAY)
	$(call dataverse_download,10.7910/DVN/83KYJY/JVJXX5)
	

clean:
	rm -rf build
	rm -rf data
