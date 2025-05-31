[![docker](https://github.com/maxonfjvipon/rultor-image-hs/actions/workflows/docker-push.yml/badge.svg)](https://github.com/maxonfjvipon/rultor-image-hs/actions/workflows/docker-push.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/maxonfjvipon/total/rultor-image-hs/master/LICENSES/MIT.txt)

This is a fork of the default Docker image
for [Rultor](https://github.com/yegor256/rultor-image). The primary distinction
is that this image is designed exclusively for Haskell projects. Unlike the main
image, which is quite large and slow to build, this one is significantly smaller
and faster.

Docker Hub
as [`maxonfjvipon/rultor-image-hs`](https://hub.docker.com/r/maxonfjvipon/rultor-image-hs).

This image has Ubuntu 22.04 and the following packages, in their latest
versions:

* Git
* sshd
* Haskell (GHC and Cabal)
* Ruby (left intentionally, to use `xcop` and `pdd` utilities)

Feel free to add yours by submitting a pull request.
