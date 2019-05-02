#!/bin/bash
if [[ $( git diff --name-only HEAD~1..HEAD webpack/ package.json | wc -l ) -ne 0 ]]; then
  REPO_SLUG_ARRAY=(${TRAVIS_REPO_SLUG//\// })
  REPO_OWNER=${REPO_SLUG_ARRAY[0]}
  REPO_NAME=${REPO_SLUG_ARRAY[1]}
  DEPLOY_PATH=storybook-static


  DEPLOY_SUBDOMAIN_UNFORMATTED_LIST=()
  if [ "$TRAVIS_PULL_REQUEST" != "false" ]
  then
    npm run build-storybook -c storybook -o .out
    DEPLOY_SUBDOMAIN_UNFORMATTED_LIST+=(${TRAVIS_PULL_REQUEST}-pr)
  fi


  for DEPLOY_SUBDOMAIN_UNFORMATTED in "${DEPLOY_SUBDOMAIN_UNFORMATTED_LIST[@]}"
  do
    echo $DEPLOY_SUBDOMAIN_UNFORMATTED
    DEPLOY_SUBDOMAIN=`echo "$DEPLOY_SUBDOMAIN_UNFORMATTED" | sed -r 's/[\/|\.]+/\-/g'`
    DEPLOY_DOMAIN=https://${DEPLOY_SUBDOMAIN}-${REPO_NAME}-${REPO_OWNER}.surge.sh
    surge --project ${DEPLOY_PATH} --domain $DEPLOY_DOMAIN;
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]
    then
      # Using the Issues api instead of the PR api
      # Done so because every PR is an issue, and the issues api allows to post general comments,
      # while the PR api requires that comments are made to specific files and specific commits
      GITHUB_PR_COMMENTS=https://api.github.com/repos/${TRAVIS_REPO_SLUG}/issues/${TRAVIS_PULL_REQUEST}/comments
      curl -H "Authorization: token ${GITHUB_API_TOKEN}" --request POST ${GITHUB_PR_COMMENTS} --data '{"body":"Travis automatic deployment: '${DEPLOY_DOMAIN}'"}'
    fi
  done
fi
