#!/bin/bash

#-----------------------------------
# Define function for confirmations
#-----------------------------------
confirm() {
    read -r -p "$@ [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            echo "Uh oh"
            echo "exiting..."
            exit 1
            ;;
    esac
}

#-----------------------------------
# Check in correct directory
#-----------------------------------
echo "Moving to saturn"
earth=$(find . -type d -name "earth")
cd $earth/saturn
echo "In directory: $PWD"

#-----------------------------------
# Tag and push
#-----------------------------------
now=$(date +'%Y%m%d%H%M')
tag_name="cb-$now"
echo "Tagging as $tag_name"

git tag $tag_name
git push origin $tagname

#-----------------------------------
# Continue only if build succeeds
#-----------------------------------
confirm "Did the build succeed?"

#-----------------------------------
# Check in correct andromeda directory
#-----------------------------------
echo "Moving to Andromeda"
andromeda=$(find $HOME -type d -name "andromeda")
cd $andromeda
echo "In directory: $PWD"

#-----------------------------------
# Continue only if image_tags match
#-----------------------------------
commit_hash=`git rev-parse HEAD`
image_tag=${commit_hash:0:7}
bold=$(tput bold)
confirm "Does the image tag on #k8s-notification match ${bold}'$image_tag'?"

echo "Commence creating new manifest file for kubernetes!"
echo "Switching to deploy/fanp-stg and pulling"
git checkout deploy/fanp-stg && git pull -r
read -r -p "What is the branch name? " branch_name
echo "Checking out branch $branch_name"
echo "Updating SATURN_IMAGE_TAG"
echo $image_tag > bin/saturn/SATURN_IMAGE_TAG
echo "Running gen_kustomize.sh"
./bin/saturn/gen_kustomize.sh
read -r -p "Please enter a commit message" commit_message
git commit -am $commit_message
git push -u origin $branch_name
