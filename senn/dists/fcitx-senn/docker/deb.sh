#!/bin/bash

set -eu

sbcl --noinform \
     --no-userinit \
     --no-sysinit \
     --non-interactive \
     --load "/root/quicklisp/setup.lisp" \
     --load "/app/senn/bin/menu.lisp" \
     --eval "(sb-ext:save-lisp-and-die
              \"/app/senn/bin/menu\"
              :executable t
              :toplevel #'senn.bin.menu:main)"

sbcl --noinform \
     --no-userinit \
     --no-sysinit \
     --non-interactive \
     --load "/root/quicklisp/setup.lisp" \
     --load "/app/senn/dists/fcitx-senn/backend/bin/server.lisp" \
     --eval "(sb-ext:save-lisp-and-die
              \"/app/senn/dists/fcitx-senn/backend/bin/server\"
              :executable t
              :toplevel #'senn.fcitx-senn.backend.bin:main)"

cmake -DCMAKE_BUILD_TYPE=Release \
      /app/senn/dists/fcitx-senn/frontend
make
make package
cp *.deb /output/
