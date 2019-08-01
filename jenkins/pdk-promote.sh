#!/bin/bash

export GEM_SOURCE="https://artifactory.delivery.puppetlabs.net/artifactory/api/gems/rubygems/"

source /usr/local/rvm/scripts/rvm
#rvm list rubies
rvm use 2.1.9 || exit 1

if [ "$GIT_BRANCH" = "origin/master" ]; then
  echo "GIT_BRANCH is 'origin/master', we're doing it live!"
  do_commit=true
else
  echo "GIT_BRANCH ('$GIT_BRANCH') != 'origin/master', no-op mode engaged..."
  do_commit=false
fi

# Install script deps
bundle install --without development --path .bundle || exit 1

# Check for newer PDK release
bundle exec ruby update-pdk-release-file.rb || exit 1

# See if that generated a diff
change_status=$(git diff --exit-code > /dev/null)

if [ "$change_status" -ne 0 ]; then
  # Grab the new release ENV vars
  source pdk-release.env

  git_cmds=()

  # Commit and tag changes
  git_cmds+=("git commit -a -m \"Promote PDK $PDK_VERSION\"")
  git_cmds+=("git tag -a \"$PDK_VERSION\" -m \"Release PDK $PDK_VERSION\"")

  # Push to origin to trigger docker-hub build for "nightly" tag as
  # well as an "x.y.z.b..." tag
  git_cmds+=("git push origin master --follow-tags")

  # Check if this is a stable release
  if [ "$PDK_RELEASE_TYPE" = "release" ]; then
    echo "PDK release type is 'release', will update 'stable' branch..."

    # Checkout and reset stable branch to head of master
    git_cmds+=("git checkout -B stable")

    # Push to origin to trigger docker-hub build for "latest" tag
    git_cmds+=("git push origin stable")
  fi

  if [ "$do_commit" = true ]; then
    # We are running from origin/master so we should actually do things
    for cmd in "${git_cmds[@]}"; do 
      $cmd || exit 1
    done
  else
    # We are running from a branch, so just echo what we would do 
    for cmd in "${git_cmds[@]}"; do 
      echo "no-op: $cmd"
    done
  fi
fi
