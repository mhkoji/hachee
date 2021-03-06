# Senn Input Method

Input method based on Hachee for the Japanese language

## Emacs

Add the code below to your .emacs file.

```lisp
(defvar senn-elisp-dir
  "<path/to/Hachee>/senn/dists/emacs/elisp/")
(push senn-elisp-dir load-path)
(load (expand-file-name "./leim-list.el" senn-elisp-dir))
```

### Dump the Server (optional)

```
% cd <path/to/Hachee>/senn/dists/emacs/
% ros dump executable bin/server.ros -o bin/server
```

## Fcitx

### Install via dpkg

#### Build the Deb file

##### Docker

```
% cd <path/to/Hachee>
% git submodule update -i
% docker build . -t fcitx-deb -f senn/dists/fcitx-senn/docker/deb.dockerfile
% docker run -v $PWD/output:/output -t fcitx-deb
% ls output
fcitx-senn-0.0.1-Linux.deb
```

##### Command Line

```
% cd <path/to/Hachee>/senn/dists/fcitx-senn/
% ros dump executable backend/bin/server.ros -o backend/bin/server
% mkdir frontned/build
% cd frontned/build
% cmake -DCMAKE_BUILD_TYPE=Release ..
% make && make package
```

#### Install

```
% sudo dpkg -i fcitx-senn-0.0.1-Linux.deb
```

#### Uninstall

```
% sudo dpkg -P fcitx-senn
```

### Install from Command Line

```
% cd <path/to/Hachee>/dists/fcitx-senn/backend
% ros dump executable bin/server.ros -o bin/server
% chmod +x bin/server
% sudo mkdir /usr/lib/senn
% sudo mv bin/server /usr/lib/senn

% sudo apt install -y fcitx-libs-dev
% mkdir <path/to/Hachee>/senn/dists/fcitx-senn/frontend/build
% cd <path/to/Hachee>/senn/dists/fcitx-senn/frontend/build
% sudo make install

% /usr/lib/senn/server
% fcitx restart
```

#### Uninstall

Manually delete the objects installed by `sudo make install` as well as `/usr/lib/senn`, which you created explicitly.
The paths of the installed objects are found in the log messages.

```
...
Install the project...
-- Install configuration: ""
-- Up-to-date: /usr/share/fcitx/addon/fcitx-senn.conf
-- Up-to-date: /usr/share/fcitx/inputmethod/senn.conf
-- Installing: /usr/lib/x86_64-linux-gnu/fcitx/fcitx-senn.so
```

Thus, you can uninstall fcitx-senn by the following commands:

```
% sudo rm -rf /usr/lib/senn
% sudo rm -rf /usr/share/fcitx/addon/fcitx-senn.conf
% sudo rm -rf /usr/share/fcitx/inputmethod/senn.conf
% sudo rm -rf /usr/lib/x86_64-linux-gnu/fcitx/fcitx-senn.so
```

## iBus

### Install via dpkg

#### Build the Deb file

##### Docker

```
% cd <path/to/Hachee>
% docker build . -t ibus-deb -f senn/dists/ibus-senn/docker/deb.dockerfile
% docker run -v $PWD/output:/output -t ibus-deb
% ls output
ibus-senn_0.0.1_all.deb
```

### Install from Command Line

```
% /usr/lib/senn/server

% sudo apt install -y gnome-common libibus-1.0-dev
% cd <path/to/Hachee>/dists/ibus-senn/frontend
% ./autogen.sh
% make && sudo make install
% ibus-daemon -drx
```

## Windows (WIP)

- Build tip
- Run `cmd.exe` as administrator and execute `C:\WINDOWS\system32>regsvr32.exe <path\to\Release\dir>\tip.dll`
