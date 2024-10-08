#!/bin/sh

#Original source https://gist.github.com/vidavidorra/548ffbcdae99d752da02

if [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ] && [ "$TRAVIS_REPO_SLUG" == "clenemt/docdash" ]; then

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo '正在设置脚本...'
# Exit with nonzero exit code if anything fails
set -e

# Get the current gh-pages branch
git clone -b gh-pages http://github.com/$TRAVIS_REPO_SLUG repo
cd repo

##### Configure git.
# Set the push default to simple i.e. push only the current branch.
git config --global push.default simple
# Pretend to be an user called Travis CI.
git config user.name "Travis CI"
git config user.email "travis@travis-ci.org"

# Remove everything currently in the gh-pages branch.
# GitHub is smart enough to know which files have changed and which files have
# stayed the same and will only update the changed files. So the gh-pages branch
# can be safely cleaned, and it is sure that everything pushed later is the new
# documentation.
rm -rf *

# Need to create a .nojekyll file to allow filenames starting with an underscore
# to be seen on the gh-pages site. Therefore creating an empty .nojekyll file.
echo "" > .nojekyll

################################################################################
##### Generate JSDOC documents.          #####
echo '复制生成的 JSDoc 代码文档...'
cp -R ../fixtures-doc/* ./ ;

################################################################################
##### Upload the documentation to the gh-pages branch of the repository.   #####
# Only upload if JSDoc successfully created the documentation.
# Check this by verifying that the file index.html exists
if [ -f "index.html" ]; then

    echo 'Uploading documentation to the gh-pages branch...'
    # Add everything in this directory to the
    # gh-pages branch.
    # GitHub is smart enough to know which files have changed and which files have
    # stayed the same and will only update the changed files.
    git add --all

    # Commit the added files with a title and description containing the Travis CI
    # build number and the GitHub commit reference that issued this build.
    git commit -m "Deploy code docs to GitHub Pages Travis build: ${TRAVIS_BUILD_NUMBER}" -m "Commit: ${TRAVIS_COMMIT}"

    # Force push to the remote gh-pages branch.
    # The ouput is redirected to /dev/null to hide any sensitive credential data
    # that might otherwise be exposed.
    git push --force "https://${GH_REPO_TOKEN}@github.com/${TRAVIS_REPO_SLUG}" > /dev/null 2>&1
else
    echo '' >&2
    echo '警告：未找到文档（html）文件！' >&2
    echo '警告：不会将文档推送到 GitHub！' >&2
    exit 1
fi

fi