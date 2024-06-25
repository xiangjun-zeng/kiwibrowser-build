git config --global http.proxy 'socks5://192.168.31.84:1080' 
git config --global https.proxy 'socks5://192.168.31.84:1080'

export proxy="http://192.168.31.84:1081"
export http_proxy=$proxy
export https_proxy=$proxy

echo "CC=ccache clang -Qunused-arguments"  
echo "CXX=ccache clang++ -Qunused-arguments"  
echo "START_TIME=$(date '+%s')"  

sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo swapoff -a
sudo rm -f /mnt/swapfile


export DEPOT_TOOLS_DIR=$PWD/depot_tools
export PATH=$DEPOT_TOOLS_DIR:$DEPOT_TOOLS_DIR/python2_bin:$DEPOT_TOOLS_DIR/python_bin:$PATH


cd src
curl "https://omahaproxy.appspot.com/all" | grep -Fi "android,stable" | cut -f3 -d"," | awk '{split($0,a,"."); print "MAJOR=" a[1] "\nMINOR=" a[2] "\nBUILD=" a[3] "\nPATCH=" a[4]}' > chrome/VERSION

gclient runhooks


cat .build/android_arm/args.gn | sed "s#target_cpu = \"arm\"#target_cpu = \"arm64\"#" | sed "s#android_default_version_name = \"Git\"#android_default_version_name = \"Git$(date '+%y%m%d')\"#" > out/arm64/args.gn
sed -i "s#android_default_version_code = \"1\"#android_default_version_code = \"$(date '+%y%m%d')\"#" out/arm64/args.gn
cat out/arm64/args.gn
gn gen out/arm64/


sudo fallocate -l 6G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

function compile_and_cleanup() {
    target=$1
    echo "Building $target ..."
    ninja -C out/arm64/ -j 8 $target
    echo "Cleaning up $target ..."
    rm -rf out/arm64/$target
    rm -rf  /home/runner/runners/2.317.0/_diag/*
    rm -rf  /home/runner/runners/2.317.0/_temp/*
}

# 编译各个目标并在完成后删除
compile_and_cleanup base
compile_and_cleanup chrome_java
compile_and_cleanup components/guest_view/renderer
compile_and_cleanup chrome/gpu
compile_and_cleanup components/version_info
compile_and_cleanup ui/base
compile_and_cleanup chrome/browser:resources
compile_and_cleanup chrome/browser/ui
compile_and_cleanup chrome/browser
compile_and_cleanup chrome/common
compile_and_cleanup chrome/renderer
compile_and_cleanup extensions
compile_and_cleanup services
compile_and_cleanup v8
# Set JAVA_HOME environment variable
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
echo "export JAVA_HOME=$JAVA_HOME" >> $GITHUB_ENV

compile_and_cleanup chrome_public_apk
