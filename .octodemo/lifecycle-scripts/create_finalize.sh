#! /bin/bash

#
# We can only do so much from Terraform with the initialization of the
# repository. This script will perform some extra setup steps necessary
# to initialize the repository state.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

docker run \
  -v $DIR/ansible:/ansible \
  -w /ansible \
  -e WORKFLOW_GITHUB_ACTIONS_PACKAGES_TOKEN="${WORKFLOW_GITHUB_ACTIONS_PACKAGES_TOKEN}" \
  -e OD_OCTODEMO_DEMO_APP_TOKEN="${OD_OCTODEMO_DEMO_APP_TOKEN}" \
  -e DEMO_CONTEXT_BASE64="${DEMO_CONTEXT_BASE64}" \
  ghcr.io/octodemo/container-ansible-development:base-20230503 \
  ./finalize_create_activities.yml
