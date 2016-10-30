git init
touch README.md
git add README.md
git add .gitignore
git commit -m"initial commit"
cd external
git submodule add --depth 1 -- https://github.com/fmtlib/fmt.git
git submodule add --depth 1 -- https://github.com/gabime/spdlog.git
cd ..
