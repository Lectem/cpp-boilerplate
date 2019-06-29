git init
touch README.md
git add README.md
git add .gitignore
git commit -m"initial commit"
cd external
rm -rf fmt
git submodule add --depth 1 -- https://github.com/fmtlib/fmt.git
rm -rf spdlog
git submodule add --depth 1 -- https://github.com/gabime/spdlog.git
rm -rf doctest
git submodule add --depth 1 -- https://github.com/onqtam/doctest.git
cd ..

echo "Repository is now prepared with basic dependencies"
echo "You now can remove those or commit them."
echo "You will need to update the CMakeLists.txt and CI configuration files."