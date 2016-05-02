FROM ruby:2.3

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Install apt based dependencies required to run Rails as 
# well as RubyGems. As the Ruby image itself is based on a 
# Debian image, we use apt-get to install those.
RUN apt-get update

RUN apt-get install -y --no-install-recommends \ 
  build-essential \ 
  openssh-server \
  sudo \
  nodejs 

RUN apt-get install -y --no-install-recommends \ 
  libsdl2-dev \
  libsdl2-ttf-dev \
  libpango1.0-dev \
  libgl1-mesa-dev \
  libfreeimage-dev \
  libopenal-dev \
  libsndfile-dev \
  libiconv-hook-dev \
  libxml2-dev \
  freeglut3 \
  freeglut3-dev \
  ImageMagick \
  libmagickwand-dev

RUN apt-get install -y \ 
  xauth \
  alsa-utils \
  libgl1-mesa-dri \
  libgl1-mesa-glx \
  libpangoxft-1.0-0 \
  libssl1.0.0 \
  libxss1 

#RUN apt-get install -y \
#  python-software-properties \ 
#  software-properties-common \  
#  && add-apt-repository ppa:xorg-edgers/ppa \
#  && apt-get update \
#  && apt-get install -y nvidia-352 nvidia-settings

RUN apt-get install -y \
  mesa-utils \
  binutils \
  x-window-system \
  module-init-tools \
  && wget -O /tmp/nvidia-driver.run http://us.download.nvidia.com/XFree86/Linux-x86_64/352.63/NVIDIA-Linux-x86_64-352.63.run \
  && sh /tmp/nvidia-driver.run -a -N --ui=none --no-kernel-module \
  && rm /tmp/nvidia-driver.run

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH config
RUN mkdir /var/run/sshd \
  && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && echo "export VISIBLE=now" >> /etc/profile \
  && echo "  X11Forwarding yes" >> /etc/ssh/ssh_config \
  && echo "  X11DisplayOffset 10" >> /etc/ssh/ssh_config \
  && echo "  X11UseLocalhost no" >> /etc/ssh/ssh_config \
  && echo "  AddressFamily inet" >> /etc/ssh/ssh_config \
  && echo 'root:root' | chpasswd
ENV NOTVISIBLE "in users profile"

# ADD an user
RUN adduser --disabled-password --gecos '' bomberman \
  && usermod -a -G video bomberman \
  && usermod -a -G sudo bomberman \
  && usermod -a -G dialout bomberman \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo 'bomberman:bomberman' | chpasswd

# SET ENV Gems
ENV HOME=/home/bomberman \
  APP=/usr/src/app

# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
RUN mkdir -p $HOME \
  && mkdir -p $APP \
  && chown -R bomberman:bomberman $APP \
  && gem install bundler \
  && echo "PATH=$PATH" >> /etc/profile \
  && echo "export GEM_HOME=/usr/local/bundle" >> /etc/profile \
  && echo "GEM_HOME=/usr/local/bundle" >> /etc/environment \
  && chown -R bomberman:bomberman $HOME

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
WORKDIR $APP
COPY Gemfile Gemfile.lock $APP/
RUN bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . ./
RUN chown -R bomberman:bomberman $APP

# Expose port 3000 to the Docker host, so we can access it 
# from the outside.
USER bomberman:bomberman
EXPOSE 22
EXPOSE 3000

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
#CMD ["/usr/bin/sudo", "/usr/sbin/sshd", "-D"]
CMD ["ruby", "main.rb"]

