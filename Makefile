parsers-version=master
graphchi-version=memory
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

prepare_libpvm:
	mkdir -p build
	git clone https://github.com/cadets/libpvm-rs.git
	cd build/libpvm-rs && git submodule update --init
	cd build/libpvm-rs/build && cmake .. && make

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
	$(call dataverse_download,10.7910/DVN/MPUCQU/BHQBB9)

download_wget_long:
	mkdir -p data
	$(call dataverse_download,10.7910/DVN/8GKEON/OFFMN3)
	$(call dataverse_download,10.7910/DVN/8GKEON/57BKKU)
	$(call dataverse_download,10.7910/DVN/8GKEON/YKHWW4)
	$(call dataverse_download,10.7910/DVN/8GKEON/AQLIIL)

download_cadets_e3:
	mkdir -p data
	cd data && git clone git@github.com:michael-hahn/cadets-e3.git

download_theia_e3:
	mkdir -p data
	cd data && git clone git@github.com:michael-hahn/theia-e3.git

download_camflow_apt:
	mkdir -p data
	cd data && git clone git@github.com:michael-hahn/camflow-apt.git

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

run_cadets:
	cd build/parsers && make cadets_prepare && make cadets_train && make cadets_attack
	cd build/graphchi-cpp && make run_cadets && make run_cadets_attack
	cd build/modeling && python model.py --train_dir ../../data/train_cadets/ --test_dir ../../data/test_cadets/

cadets: prepare prepare_libpvm download_cadets run_cadets

run_cadets_e3:
	cd data/cadets-e3 && mkdir -p edgelists_benign && mkdir -p edgelists_attack && mkdir -p train && mkdir -p test
	cd data/cadets-e3/train && mkdir -p base && mkdir -p stream
	cd data/cadets-e3/test && mkdir -p base && mkdir -p stream
	cd build/parsers/cdm && make cadets_e3
	cd build/graphchi-cpp && make cadets_e3
	cd build/modeling && python model.py --train_dir ../../data/cadets-e3/train_sketch/ --test_dir ../../data/cadets-e3/test_sketch/

cadets_e3: prepare download_cadets_e3 run_cadets_e3

run_theia_e3:
	cd data/theia-e3 && mkdir -p edgelists_benign && mkdir -p edgelists_attack && mkdir -p train && mkdir -p test
	cd data/theia-e3/train && mkdir -p base && mkdir -p stream
	cd data/theia-e3/test && mkdir -p base && mkdir -p stream
	cd build/parsers/cdm && make theia_e3
	cd build/graphchi-cpp && make theia_e3
	cd build/modeling && python model.py --train_dir ../../data/theia-e3/train_sketch/ --test_dir ../../data/theia-e3/test_sketch/

theia_e3: prepare download_theia_e3 run_theia_e3

run_camflow_apt:
	cd data/camflow-apt && mkdir -p edgelists_benign && mkdir -p edgelists_attack && mkdir -p train && mkdir -p test
	cd data/camflow-apt/train && mkdir -p base && mkdir -p stream
	cd data/camflow-apt/test && mkdir -p base && mkdir -p stream
	cd build/parsers/cdm && make camflow_apt
	cd build/graphchi-cpp && make camflow_apt
	cd build/modeling && python model.py --train_dir ../../data/camflow-apt/train_sketch/ --test_dir ../../data/camflow-apt/test_sketch/

camflow_apt: prepare download_camflow_apt run_camflow_apt

define parse_camflow_interval
	cd build/parsers/cdm && number=0 ; while [ $$number -le 124 ] ; do \
		python ProvParser/provparser/up.py -v -m -S $(1) -i ../../../data/camflow-apt/edgelists_benign/camflow-benign.txt.$$number -b ../../../data/camflow-apt/train/base/base-camflow-benign-$$number.txt -s ../../../data/camflow-apt/train/stream/stream-camflow-benign-$$number.txt ; \
		number=`expr $$number + 11` ; \
	done
	cd build/parsers/cdm && number=0 ; while [ $$number -le 24 ] ; do \
		python ProvParser/provparser/up.py -v -m -S $(1) -i ../../../data/camflow-apt/edgelists_attack/camflow-attack.txt.$$number -b ../../../data/camflow-apt/test/base/base-camflow-attack-$$number.txt -s ../../../data/camflow-apt/test/stream/stream-camflow-attack-$$number.txt ; \
		number=`expr $$number + 8` ; \
	done
endef

define run_camflow_interval
	cd data/camflow-apt && mkdir -p sketches
	cd build/graphchi-cpp && number=0 ; while [ $$number -le 124 ] ; do \
		bin/streaming/main filetype edgelist file ../../data/camflow-apt/train/base/base-camflow-benign-$$number.txt niters 100000 stream_file ../../data/camflow-apt/train/stream/stream-camflow-benign-$$number.txt decay 500 lambda 0.02 window 500 interval $(1) multiple 1 sketch_file ../../data/camflow-apt/sketches/sketch-benign-$$number.txt chunkify 1 chunk_size 5 ; \
		rm -rf ../../data/camflow-apt/train/base/base-camflow-benign-$$number.txt.* ; \
		rm -rf ../../data/camflow-apt/train/base/base-camflow-benign-$$number.txt_* ; \
		number=`expr $$number + 11` ; \
	done
	cd build/graphchi-cpp && number=0 ; while [ $$number -le 24 ] ; do \
		bin/streaming/main filetype edgelist file ../../data/camflow-apt/test/base/base-camflow-attack-$$number.txt niters 100000 stream_file ../../data/camflow-apt/test/stream/stream-camflow-attack-$$number.txt decay 500 lambda 0.02 window 500 interval $(1) multiple 1 sketch_file ../../data/camflow-apt/sketches/sketch-attack-$$number.txt chunkify 1 chunk_size 5 ; \
		rm -rf ../../data/camflow-apt/test/base/base-camflow-attack-$$number.txt.* ; \
		rm -rf ../../data/camflow-apt/test/base/base-camflow-attack-$$number.txt_* ; \
		number=`expr $$number + 8` ; \
	done
endef

define analyze_camflow_interval
	cd build/modeling && number=0; while [ $$number -le 124 ] ; do \
		python interval.py -n $(1) -i ../../data/camflow-apt/sketches/sketch-benign-$$number.txt >> summary.txt ; \
		number=`expr $$number + 11` ; \
	done
	cd build/modeling && number=0; while [ $$number -le 24 ] ; do \
		python interval.py -n $(1) -i ../../data/camflow-apt/sketches/sketch-attack-$$number.txt >> summary.txt ; \
		number=`expr $$number + 8` ; \
	done
endef

determine_camflow_interval:
	cd data/camflow-apt && mkdir -p edgelists_benign && mkdir -p edgelists_attack && mkdir -p train && mkdir -p test
	cd data/camflow-apt/train && mkdir -p base && mkdir -p stream
	cd data/camflow-apt/test && mkdir -p base && mkdir -p stream

	cd build/parsers/cdm && number=0 ; while [ $$number -le 15 ] ; do \
		cd ../../../data/camflow-apt/benign && mkdir camflow-benign-$$number && tar zxvf camflow-benign-$$number.gz.tar -C camflow-benign-$$number && mv camflow-benign-$$number/camflow-benign.txt.* ../edgelists_benign ; \
		cd ../../../data/camflow-apt/benign && rm -f camflow-benign-$$number.gz.tar && rm -rf camflow-benign-$$number ; \
		number=`expr $$number + 1` ; \
	done
	cd build/parsers/cdm && number=0 ; while [ $$number -le 2 ] ; do \
		cd ../../../data/camflow-apt/attack && mkdir camflow-attack-$$number && tar zxvf camflow-attack-$$number.gz.tar -C camflow-attack-$$number && mv camflow-attack-$$number/camflow-attack.txt.* ../edgelists_attack ; \
		cd ../../../data/camflow-apt/attack && rm -f camflow-attack-$$number.gz.tar && rm -rf camflow-attack-$$number ; \
		number=`expr $$number + 1` ; \
	done
	number=5000 ; while [ $$number -le 10000 ] ; do \
		$(call parse_camflow_interval,$$number) ; \
		$(call run_camflow_interval,$$number) ; \
		cd data/camflow-apt/train/base && rm * ; \
		cd data/camflow-apt/train/stream && rm * ; \
		cd data/camflow-apt/test/base && rm * ; \
		cd data/camflow-apt/test/stream && rm * ; \
		$(call analyze_camflow_interval,$$number) ; \
		cd data/camflow-apt/sketches && rm * ; \
		number=`expr $$number + 1000` ; \
	done

camflow_apt_interval: prepare download_camflow_apt determine_camflow_interval

clean:
	rm -rf build
	rm -rf data
