Quick compilation guide:
Install liblzma-dev, it's needed for configure script
sudo apt-get install liblzma-dev
Download my Git repo from https://github.com/pelya/commandergenius,
then install Android SDK, Android NDK, and "ant" tool, then launch commands
    git submodule update --init --recursive
    build.sh openttd-jgrpp
You may need to run command
    android update project -p project -t android-25
