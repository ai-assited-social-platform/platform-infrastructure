# 1. Check if Docker is installed, if not, propose installation with y/n prompt, if yes, install Docker else exit script.
# 2. Check if Linux Subsystem is installed (for Windows), if not, propose installation with y/n prompt, if yes, install WSL else exit script.
# 3. Check if Repositories are cloned, if not, clone them.
# 4. Check if Repositories are updated, if not, pull the latest changes with y/n prompt, if yes, pull changes else continue with script.
# 5. Check if images, containers exist that are not related to databases, if yes, remove them.
# 6. Run Docker Compose to set up local development environment.