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
	wget --retry-connrefused --waitretry=5 --read-timeout=30 --tries=50 --no-dns-cache https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O data/tmp.tar.gz
	cd data && tar -xzf tmp.tar.gz
	rm -f data/tmp.tar.gz
endef

download_wget:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/IA8UOS/URG8XN)
	$(call dataverse_download,10.7910/DVN/IA8UOS/1DBE7K)
	$(call dataverse_download,10.7910/DVN/IA8UOS/34QRHK)

download_streamspot:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/83KYJY/JVJXX5)

download_cadets:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/MPUCQU/GAMHTP)
	$(call dataverse_download,10.7910/DVN/MPUCQU/D6SE4T)

download_wget_long:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/8GKEON/OFFMN3)
	$(call dataverse_download,10.7910/DVN/8GKEON/57BKKU)
	$(call dataverse_download,10.7910/DVN/8GKEON/YKHWW4)
	$(call dataverse_download,10.7910/DVN/8GKEON/AQLIIL)

run_toy:
	cd build/parsers && make toy
	cd build/graphchi-cpp && make run_toy
	cd build/modeling && python model.py --train_dir ../../data/train_toy/ --test_dir ../../data/test_toy/

toy: prepare download_streamspot run_toy

run_streamspot:
	cd build/parsers && make youtube && make gmail && make vgame && make download && make cnn && make attack
	cd build/graphchi-cpp && make run_youtube && make run_gmail && make run_vgame && make run_download && make run_cnn && make run_attack
	cd build/modeling && python model.py --train_dir ../../data/train_streamspot/ --test_dir ../../data/test_streamspot/

streamspot: prepare download_streamspot run_streamspot

run_wget:
	cd build/parsers && make wget_train && make wget_baseline_attack && make wget_interval_attack
	cd build/graphchi-cpp && make run_wget && make run_wget_baseline_attack && make run_wget_interval_attack
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_baseline/
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_interval/

wget: prepare download_wget run_wget

run_wget_subset:
	cd build/graphchi-cpp && make run_wget_subset && make run_wget_baseline_attack && make run_wget_interval_attack
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_baseline/
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_interval/

wget_subset: prepare download_wget run_wget_subset

run_cadets:
	cd build/parsers && make cadets_prepare && make cadets_train && make cadets_attack
	cd build/graphchi-cpp && make run_cadets && make run_cadets_attack
	cd build/modeling && python model.py --train_dir ../../data/train_cadets/ --test_dir ../../data/test_cadets/

cadets: prepare download_cadets run_cadets

clean:
	rm -rf build
	rm -rf data
