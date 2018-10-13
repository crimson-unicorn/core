parsers-version=eval
graphchi-version=eval
modeling-version=eval
number=0
attack-type=baseline

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
	git clone https://github.com/crimson-unicorn/output.git

prepare_libpvm:
	mkdir -p build
	git clone https://github.com/cadets/libpvm-rs.git
	cd build/libpvm-rs && git submodule update --init
	cd build/libpvm-rs/build && cmake .. && make

prepare: prepare_parsers prepare_graphchi prepare_modeling prepare_output

define dataverse_download
	wget https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:$(1) -O data/tmp.tar.gz
	cd data && tar -xzf tmp.tar.gz
	rm -f data/tmp.tar.gz
endef

download_wget:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/IA8UOS/URG8XN)
	$(call dataverse_download,10.7910/DVN/IA8UOS/1DBE7K)
	$(call dataverse_download,10.7910/DVN/IA8UOS/34QRHK)

download_wget_subset:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/IA8UOS/PJKEMZ)
	$(call dataverse_download,10.7910/DVN/IA8UOS/RHTYM9)

download_streamspot:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/83KYJY/JVJXX5)

download_wget_long:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/8GKEON/OFFMN3)
	$(call dataverse_download,10.7910/DVN/8GKEON/57BKKU)
	$(call dataverse_download,10.7910/DVN/8GKEON/YKHWW4)
	$(call dataverse_download,10.7910/DVN/8GKEON/gAQLIIL)

run_toy:
	cd build/parsers && make toy
	cd build/graphchi-cpp && make run_toy
	cd build/modeling && python model.py --train_dir ../../data/train_toy/ --test_dir ../../data/test_toy/

toy: prepare download_streamspot run_toy

run_streamspot:
	cd build/parsers && make youtube && make gmail && make vgame && make download && make cnn && make attack && make streamspot_statistics
	cd build/graphchi-cpp && make run_youtube && make run_gmail && make run_vgame && make run_download && make run_cnn && make run_attack
	cd build/modeling && python model.py --train_dir ../../data/train_streamspot/ --test_dir ../../data/test_streamspot/

streamspot: prepare download_streamspot run_streamspot

run_wget:
	cd build/parsers && make wget_train && make wget_baseline_attack && make wget_interval_attack && make wget_statistics
	cd build/graphchi-cpp && make run_wget && make run_wget_baseline_attack && make run_wget_interval_attack
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_baseline/
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_interval/	

wget: prepare download_wget run_wget

run_wget_subset:
	cd build/parsers && make wget_train_subset && make wget_baseline_attack_subset
	cd build/graphchi-cpp && make run_wget_subset && make run_wget_baseline_attack_subset
	cd build/modeling && python model.py --train_dir ../../data/train_wget/ --test_dir ../../data/test_wget_baseline/
	mv build/modeling/stats.csv output/stats-s-2000-h-3-w-450-i-10000-real.csv

wget_subset: prepare download_wget_subset run_wget_subset

run_single_benign_wget:
	cd build/parsers && make number=$(number) single_wget_train
	cd build/graphchi-cpp && make number=$(number) run_single_benign_wget

eval_benign_wget: prepare download_wget run_single_benign_wget

run_single_attack_wget:
	cd build/parsers && make number=$(number) attack-type=$(attack-type) single_wget_attack
	cd build/graphchi-cpp && make number=$(number) attack-type=$(attack-type) run_single_attack_wget

eval_attack_wget: prepare download_wget run_single_attack_wget

run_cadets:
	cd build/parsers && make cadets_prepare && make cadets_train && make cadets_attack & make cadets_statistics
	cd build/graphchi-cpp && make run_cadets && make run_cadets_attack
	cd build/modeling && python model.py --train_dir ../../data/train_cadets/ --test_dir ../../data/test_cadets/

cadets: prepare prepare_libpvm download_cadets run_cadets

clean:
	rm -rf build
	rm -rf data
