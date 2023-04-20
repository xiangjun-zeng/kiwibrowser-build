git config --global http.proxy 'socks5://192.168.31.84:1080' 
git config --global https.proxy 'socks5://192.168.31.84:1080'

export proxy="http://192.168.31.84:1081"
export http_proxy=$proxy
export https_proxy=$proxy

echo "CC=ccache clang -Qunused-arguments"  
echo "CXX=ccache clang++ -Qunused-arguments"  
echo "START_TIME=$(date '+%s')"  
mkdir -p "$PWD/run"
echo "FLAG_STOP=$PWD/run/ninjaStop"  
echo "ROOT=$PWD"  
git config --global user.email "wanluoliang@126.com"
git config --global user.name "wankaiming"


git clone --progress --branch main -v --depth 1 "https://github.com/wankaiming/kiwibrowser-ccache-arm64.git" $HOME/cache


mkdir -p $HOME/.ccache/
echo 'compiler_check = none' >> $HOME/.ccache/ccache.conf
echo "stats = false" >> $HOME/.ccache/ccache.conf
echo 'max_size = 20G' >> $HOME/.ccache/ccache.conf
echo "base_dir = $HOME" >> $HOME/.ccache/ccache.conf
echo "cache_dir = $HOME/cache" >> $HOME/.ccache/ccache.conf
echo "hash_dir = false" >> $HOME/.ccache/ccache.conf

sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo swapoff -a
sudo rm -f /mnt/swapfile


git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
export DEPOT_TOOLS_DIR=$PWD/depot_tools
export PATH=$DEPOT_TOOLS_DIR:$DEPOT_TOOLS_DIR/python2_bin:$DEPOT_TOOLS_DIR/python_bin:$PATH


git clone --depth 1 "https://github.com/wankaiming/dependencies.git" .cipd
cp .cipd/.gclient .
cp .cipd/.gclient_entries .


sudo apt-get update
sudo apt-get install -y python openjdk-8-jdk-headless libncurses5 ccache
sudo update-java-alternatives --set java-1.8.0-openjdk-amd64
git clone --depth 1 "https://github.com/wankaiming/kiwibrowser-src.git" src
cd src
curl "https://omahaproxy.appspot.com/all" | grep -Fi "android,stable" | cut -f3 -d"," | awk '{split($0,a,"."); print "MAJOR=" a[1] "\nMINOR=" a[2] "\nBUILD=" a[3] "\nPATCH=" a[4]}' > chrome/VERSION
sudo bash install-build-deps.sh --no-chromeos-fonts
build/linux/sysroot_scripts/install-sysroot.py --arch=i386
build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
keytool -genkey -v -keystore keystore.jks -alias dev -keyalg RSA -keysize 2048 -validity 10000 -storepass public_password -keypass public_password -dname "cn=Kiwi Browser, ou=Actions, o=Kiwi Browser, c=GitHub"
gclient runhooks


 
cd src
mkdir -p out/arm64/
cat .build/android_arm/args.gn | sed "s#target_cpu = \"arm\"#target_cpu = \"arm64\"#" | sed "s#android_default_version_name = \"Git\"#android_default_version_name = \"Git$(date '+%y%m%d')\"#" > out/arm64/args.gn
sed -i "s#android_default_version_code = \"1\"#android_default_version_code = \"$(date '+%y%m%d')\"#" out/arm64/args.gn
cat out/arm64/args.gn
gn gen out/arm64/


sleep $(expr 60 \* 60 \* 5 + ${START_TIME}  - $(date "+%s")) && touch "$FLAG_STOP" && ( killall ninja-linux64 || true ) || ( test $? == 143 && echo sleep canceld ) &

apt install ninja-build

sudo fallocate -l 6G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

ninja -C out/arm64/ -j 8 base 
ninja -C out/arm64/ -j 8 chrome_java 
ninja -C out/arm64/ -j 8 components/guest_view/renderer 
ninja -C out/arm64/ -j 8 chrome/gpu 
ninja -C out/arm64/ -j 8 components/version_info 
ninja -C out/arm64/ -j 8 ui/base 
ninja -C out/arm64/ -j 8 chrome/browser:resources 
ninja -C out/arm64/ -j 8 chrome/browser/ui 
ninja -C out/arm64/ -j 8 chrome/browser 
ninja -C out/arm64/ -j 8 chrome/common 
ninja -C out/arm64/ -j 8 chrome/renderer 
ninja -C out/arm64/ -j 8 extensions 
ninja -C out/arm64/ -j 8 services 
ninja -C out/arm64/ -j 8 v8 
ninja -C out/arm64/ -j 4 chrome_public_apk