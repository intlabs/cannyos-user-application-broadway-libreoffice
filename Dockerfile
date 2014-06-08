#
# CannyOS User Storage Dropbox
#
# https://github.com/intlabs/cannyos-user-application-broadway-libreoffice
#
# Copyright 2014 Pete Birley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Pull base image.
FROM intlabs/dockerfile-cannyos-ubuntu-14_04-fuse

# Set environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Set the working directory
WORKDIR /

#****************************************************
#                                                   *
#         INSERT COMMANDS BELLOW THIS               *
#                                                   *
#****************************************************

#Allow remote root login with password
RUN sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && /etc/init.d/ssh restart

#Install the broadway gtk3 ppa for ubuntu
RUN add-apt-repository ppa:malizor/gtk-broadway -y
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install broadwayd -y

#Build libreoffice
RUN apt-get install -y gedit
WORKDIR /source
RUN apt-get install -y libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev wget curl git
RUN apt-get build-dep libreoffice -y
RUN git clone git://anongit.freedesktop.org/libreoffice/core libreoffice
WORKDIR /source/libreoffice
RUN ./autogen.sh --enable-gtk3 --without-java
RUN make



#****************************************************
#                                                   *
#         ONLY PORT RULES BELLOW THIS               *
#                                                   *
#****************************************************

#SSH
#EXPOSE 22/tcp

#HTTP (broadway)
EXPOSE 8080/tcp

#****************************************************
#                                                   *
#         NO COMMANDS BELLOW THIS                   *
#                                                   *
#****************************************************

# Add startup 
ADD /CannyOS/startup.sh /CannyOS/startup.sh
RUN chmod +x /CannyOS/startup.sh

# Add post-install script
#ADD /CannyOS/post-install.sh /CannyOS/post-install.sh
#RUN chmod +x /CannyOS/post-install.sh

# Define default command.
ENTRYPOINT ["/CannyOS/startup.sh"]