# core

This `paper` branch is archived for [Unicorn](https://www.ndss-symposium.org/wp-content/uploads/2020/02/24046-paper.pdf) paper.
Unicorn has involved since; we try out best to maintain the latest stable version on the `master` branch.

## Prepare

Download dependencies ([parsers](https://github.com/crimson-unicorn/parsers), [graphchi](https://github.com/crimson-unicorn/graphchi-cpp) and [modeling](https://github.com/crimson-unicorn/modeling)):
```
make prepare
```

It is possible to specify the dependencies version (if unspecified master branch is used by default):
```
make parsers-version=<branch or tag> graphchi-version=<branch or tag> modeling-version=<branch or tag> prepare
```

For example to use the `selective` branch/tag for the graphchi dependency:
```
make graphchi-version=selective prepare
```

## Download datasets

To download, for example the wget datasets:
```
make download_wget
```

## Clean

Clean everything:
```
make clean
```
