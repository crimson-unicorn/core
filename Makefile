parsers-version=master
graphci-version=master
modeling-version=master

prepare:
	mkdir -p build
	cd build && git clone --single-branch -b $(parsers-version) https://github.com/crimson-unicorn/parsers
	cd build && git clone --single-branch -b $(graphchi-version) https://github.com/crimson-unicorn/graphchi-cpp
	cd build && git clone --single-branch -b $(modeling-version)  https://github.com/crimson-unicorn/modeling

clean:
	rm -rf build
