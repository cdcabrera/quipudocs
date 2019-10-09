#!/bin/bash
#
#
# main()
#
{
  set -e
  set -x

  GREEN="\e[32m"
  YELLOW="\e[33m"
  NOCOLOR="\e[39m"
  DIFF_CHECK=$(git diff | grep '^+' | grep -v '+++' | grep -v 'Last updated' | wc -l)

  # filter out pull requests
  if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo -e "${YELLOW}Exiting early, pull request${NOCOLOR}"
    exit 0;
  fi

  # filter out forked repositories
  if [[ $REPO != *"$TRAVIS_REPO_SLUG"* ]]; then
    echo -e "${YELLOW}Exiting early, not master repository${NOCOLOR}"
    exit 0;
  fi

  # if auto deploy active filter out timestamp only updates
  if [ "${AUTO_DEPLOY}" = "true" ] && [[ "${DIFF_CHECK}" = "0" ]]; then
    echo -e "${YELLOW}$(git diff --compact-summary){$NOCOLOR}"
    echo -e "${YELLOW}Exiting early, no significant changes${NOCOLOR}"
    exit 0;
  fi

  # filter out deployment tokens when active
  if [ "${AUTO_DEPLOY}" != "true" ] && [[ ! "$TRAVIS_COMMIT_MESSAGE" =~ "[DEPLOY]" ]]; then
    echo -e "${YELLOW}Exiting early, not a deployment${NOCOLOR}"
    exit 0;
  fi

  # filter process for specific branch and CI stage
  if [[ "${TRAVIS_BRANCH}" = "${BRANCH}" ]] && [[ $TRAVIS_BUILD_STAGE_NAME == *"Build"* ]]; then
    set +x
    openssl aes-256-cbc \
            -K `env | grep 'encrypted_.*_key' | cut -f2 -d '='` \
            -iv `env | grep 'encrypted_.*_iv' | cut -f2 -d '='` \
            -in .travis/deploy_key.enc -out .travis/deploy_key -d
    set -x

    chmod 600 .travis/deploy_key
    eval `ssh-agent -s`
    ssh-add .travis/deploy_key

    echo -e "${YELLOW}PUSHING Quipudocs build...${NOCOLOR}"

    git config --global user.name ${USER}
    git config --global user.email ${EMAIL}
    git remote add ssh-origin ${REPO}
    git checkout ${BRANCH}

    git add -f ./dist/*
    git add -f ./docs/*
    git commit -m "chore(build): deploy" -m "[skip ci]"
    git push ssh-origin ${BRANCH} --quiet

    echo -e "${GREEN}COMPLETED Quipudocs build${NOCOLOR}"
    exit 0;
  fi

  # fallback messaging
  echo -e "${YELLOW}Exiting, not ${BRANCH} branch or build stage${NOCOLOR}"
  exit 0;
}
