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
  yasm libx265-dev \
  libnuma-dev \
  libvpx-dev\
  libfdk-aac-dev \
  libmp3lame-dev \
  libx264-dev \
  libopus-dev 

CORES=`cat /proc/cpuinfo | grep processor | wc -l`

git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git                     
cd nv-codec-headers
make - j $CORES
sudo make install

mkdir ~/ffmpeg_sources
cd ~/ffmpeg_sources
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo apt-get update
sudo apt-get install -y cuda cuda-npp-10-0 cuda-npp-dev-10-0 

wget https://cloud.netfreaks.fr/s/NTTX7Qoycee334j/download -O NDI.tgz
tar xf NDI.tgz
cp -R 'NDI SDK for Linux' ~/NDI
sudo cp ~/NDI/lib/x86_64-linux-gnu/* /usr/lib/

cd ~
wget https://cloud.netfreaks.fr/s/y74PLEotawbaK5m/download -O BMDSDK10.tgz
tar xf BMDSDK10.tgz

wget https://cloud.netfreaks.fr/s/QBin2pfKKwn5rEg/download -O BMD.tgz
tar xf BMD.tgz
sudo dpkg -i x86_64/desktop*
rm -Rf x86_64

mkdir -p ~/bin
cd ~/ffmpeg_sources && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 && \
tar xjvf nasm-2.13.03.tar.bz2 && \
cd nasm-2.13.03 && \
./autogen.sh && \
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
make -j $CORES && \
make install
 
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make -j $CORES && \
make install

cd ~/ffmpeg_sources && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
make && \
make install

cd ~/ffmpeg_sources && \
wget http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz && \
tar xf libxml2-2.9.9.tar.gz && \
cd libxml2-2.9.9 && \
./configure && \
make -j $CORES && \
make install

cd ~/ffmpeg_sources && \
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.1.3.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg-4.1.3
 
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include -I/$HOME/NDI/include -I/usr/local/cuda/include -I/$HOME/BMDSDK10/Linux/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib -L/$HOME/NDI/lib/x86_64-linux-gnu -L/usr/local/cuda/lib64" \
  --extra-libs="-lpthread -lm" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libxml2 \
  --enable-libx265 \
  --enable-decklink \
  --enable-demuxer=dash \
  --enable-nonfree \
  --enable-cuda \
  --enable-cuvid \
  --enable-nvenc \
  --enable-libnpp \
  --enable-libndi_newtek

PATH="$HOME/bin:$PATH" make -j $CORES && \
make install && \

ls -laRh $HOME/bin