# Home Project Template

A `cargo-generate` template for some projects I use on my local LAN.


The install script makes some assumtions about my setup. Feel free to fork and 
modify if you'd like.

## Usage

```shell
cargo generate --git https://github.com/FreeMasen/home-project-template
🤷   Project Name: test-project
🔧   Destination: /home/user/test-project ...
🔧   project-name: test-project ...
🔧   Generating template ...
🤷   What port number should the server use?: 9999
🤷   What hostname would you like for your url?: testproject
🤷   Project description?: A test project for my home service
🔧   Moving generated files into: `/home/user/test-project`...
🔧   Initializing a fresh Git repository
✨   Done! New project created /home/user/test-project
ls ./test-project
Cargo.toml  install.sh  license.txt  README.md  src
testproject.conf  test-project.service  testproject.toml

```
