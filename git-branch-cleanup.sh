#!/bin/bash

# 1. Define the usage summary function
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Safely prunes local Git branches that have been deleted from your remote repository.

Options:
  -h, --help    Show this summary, usage options, and exit.

Behavior:
  - Fetches the latest updates from your remote and prunes obsolete tracking branches.
  - Identifies local branches marked as '[gone]'.
  - Iterates through each branch, prompting you individually before deletion.
  - Employs safe deletion ('git branch -d') to prevent accidental loss of unmerged work.
EOF
}

# 2. Check for help arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# 3. Update remote tracking branches and prune obsolete references
echo "Fetching and pruning remote tracking branches..."
git fetch --prune

# 4. Identify local branches whose upstream is gone
gone_branches=$(git branch -vv | grep ': gone]' | awk '{print $1}' | sed 's/^*//')

if [ -z "$gone_branches" ]; then
    echo "No deleted remote branches to prune locally. Your working copy is clean!"
    exit 0
fi

echo ""
echo "Found branches that are deleted on the remote. Checking each one..."
echo "----------------------------------------"

# 5. Loop over each branch individually
for branch in $gone_branches; do
    read -p "Delete local branch '$branch'? (y/N): " response
    
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$response" == "y" || "$response" == "yes" ]]; then
        git branch -d "$branch"
    else
        echo "Skipped '$branch'."
    fi
    echo "----------------------------------------"
done

echo "Review complete!"

