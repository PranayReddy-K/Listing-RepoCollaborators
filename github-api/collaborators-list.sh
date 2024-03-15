#!/bin/bash

#################
# Author : K PRANAY REDDY
# Date   : 15-03-2024
#
# This script lists all the collaborators of a specific repository
# Steps to execute script:-
# 1. Export "username" and "token"
# 2. provide two command line arguments i.e {normal repo        : ownerusername & repo_name}
#                                           {project inside org : organization_name & repo_name}
#
#################

# Helper function to check the number of command-line arguments
function helper {
    expected_cmd_args=2
    
    if [ "$#" -ne "$expected_cmd_args" ]; then
        echo "Please provide the required arguments: owner/organization_name and repo_name"
        exit 1
    fi
}

# Call the helper function to check command-line arguments
helper "$@"

# GitHub username and personal access token (better as input than hard-coding info)
USERNAME=$username
TOKEN=$token

# Storing the two command-line arguments i.e info 
REPO_OWNER=$1
REPO_NAME=$2

# GitHub API URL
API_URL="https://api.github.com"

# Function to make a GET request to the GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Send a GET request to the GitHub API with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read , write & admin access to the repository seperately 
function list_users_with_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Fetch the list of collaborators on the repository 
    
    
    # Having read access  -> triage
    read_collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.triage == true and .permissions.admin == false) | .login')"
    
    # Having write access -> maintain 
    write_collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.maintain == true and .permissions.admin == false) | .login')"
    
    # Having admin access -> admin
    admin_collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.admin == true) | .login')"

   for access_level in read write admin; do
    collaborators_var="${access_level}_collaborators"
    if [[ -z "${!collaborators_var}" ]]; then
        echo "No users with ${access_level} access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with ${access_level} access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "${!collaborators_var}"
    fi
   done

}


# Main Script


echo "Listing users with read write admin access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_access