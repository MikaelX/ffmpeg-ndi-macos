apt-get update && apt-get -y install sudo
sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev \
  libxml2-dev \
  yasm \
  libx265-dev \
  libnuma-dev \
  libvpx-dev\
  libfdk-aac-dev \
  libmp3lame-dev \
  libx264-dev \
  libopus-dev \
  libavahi-client-dev \
  libavahi-common-dev

PROJDIR=`pwd`
echo $PROJDIR
CORES=`cat /proc/cpuinfo | grep processor | wc -l`

git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git                     
cd nv-codec-headers
make - j $CORES
sudo make install

mkdir $PROJDIR/ffmpeg_sources
mkdir $PROJDIR/bin

cd $PROJDIR/ffmpeg_sources
# wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
# echo "dkpg cuda-repo --->"
# sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
# echo "<--- dkpg cuda-repo"
# sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
# sudo apt-get update
# echo "apt install --->"
# echo "31" | sudo apt install -y cuda cuda-npp-10-0 cuda-npp-dev-10-0 
# echo "<--- apt install"

wget https://cloud.netfreaks.fr/s/NTTX7Qoycee334j/download -O NDI.tgz
tar xf NDI.tgz
cp -R 'NDI SDK for Linux' $PROJDIR/NDI
sudo cp $PROJDIR/NDI/lib/x86_64-linux-gnu/* /usr/lib/

wget https://cloud.netfreaks.fr/s/y74PLEotawbaK5m/download -O BMDSDK10.tgz
tar xf BMDSDK10.tgz
cp -R 'BMDSDK10' $PROJDIR/BMDSDK10

wget https://cloud.netfreaks.fr/s/QBin2pfKKwn5rEg/download -O BMD.tgz
tar xf BMD.tgz
sudo dpkg -i x86_64/desktop*
rm -Rf x86_64

mkdir -p $PROJDIR/bin
cd $PROJDIR/ffmpeg_sources && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 && \
tar xjvf nasm-2.13.03.tar.bz2 && \
cd nasm-2.13.03 && \
./autogen.sh && \
PATH="$PROJDIR/bin:$PATH" ./configure --prefix="$PROJDIR/ffmpeg_build" --bindir="$PROJDIR/bin" && \
make -j $CORES && \
make install
 

cd $PROJDIR/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$PROJDIR/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PROJDIR/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
PATH="$PROJDIR/bin:$PATH" make -j $CORES && \
make install

cd $PROJDIR/ffmpeg_sources && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure --prefix="$PROJDIR/ffmpeg_build" --disable-shared && \
make && \
make install

cd $PROJDIR/ffmpeg_sources && \
wget http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz && \
tar xf libxml2-2.9.9.tar.gz && \
cd libxml2-2.9.9 && \
./configure && \
make -j $CORES && \
make install

cd $PROJDIR/ffmpeg_sources && \
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.1.3.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg-4.1.3
 
PATH="$PROJDIR/bin:$PATH" PKG_CONFIG_PATH="$PROJDIR/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$PROJDIR/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$PROJDIR/ffmpeg_build/include -I$PROJDIR/NDI/include -I$PROJDIR/BMDSDK10/Linux/include" \
  --extra-ldflags="-L$PROJDIR/ffmpeg_build/lib -L$PROJDIR/NDI/lib/x86_64-linux-gnu -L/usr/lib/" \
  --extra-libs="-lpthread -lm" \
  --bindir="$PROJDIR/bin" \
  --enable-gpl \
  --enable-libaom \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libxml2 \
  --enable-libx265 \
  --enable-demuxer=dash \
  --enable-nonfree \
  --enable-libndi_newtek \
  --enable-decklink \
  --enable-libass 


PATH="$PROJDIR/bin:$PATH" make -j $CORES && \
make install && \

  # --extra-cflags="-I$PROJDIR/ffmpeg_build/include -I$PROJDIR/NDI/include -I$PROJDIR/BMDSDK10/Linux/include -I/usr/local/cuda/include" \
  # --extra-ldflags="-L$PROJDIR/ffmpeg_build/lib -L$PROJDIR/NDI/lib/x86_64-linux-gnu -L/usr/lib/ -L/usr/local/cuda/lib64" \
    # --enable-cuda --enable-cuvid --enable-nvenc --enable-libnpp