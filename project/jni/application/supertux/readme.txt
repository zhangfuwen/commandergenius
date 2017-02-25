To compile Android version:
1. Use Debian or Ubuntu or MacOsX. Windows is not supported, but you can try to use Bash shell on Windows 10.
2. Install Android SDK: https://developer.android.com/studio/index.html#downloads
3. Install Android NDK: https://developer.android.com/ndk/downloads/index.html
4. Install Java and Ant: sudo apt-get install ant openjdk-8-jdk build-essential
5. Download SDL Git repo: git clone https://github.com/pelya/commandergenius
6. git submodule update --init --recursive project/jni/application/supertux/supertux
7. ./build.sh supertux

You may also use source archive at https://sourceforge.net/projects/libsdl-android/files/apk/SuperTux/
