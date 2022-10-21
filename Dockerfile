FROM jupyter/base-notebook:2022-10-17

USER root

# Install libglib2.0-bin to prevent KDE being brought in:
#   dpkg -I windows95_3.1.1_amd64.deb | grep Depends
#    Depends: libgtk-3-0, libnotify4, libnss3, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin
# Install fonts-noto-mono to workaround a font problem in the XFCE terminal
RUN apt-get -y update && \
  apt-get install -y \
  dbus-x11 \
  git \
  firefox \
  fonts-noto-mono \
  libglib2.0-bin \
  xfce4 \
  xfce4-panel \
  xfce4-session \
  xfce4-settings \
  xorg \
  xubuntu-icon-theme

# Remove xfce4-screensaver to prevent screen lock
ARG TURBOVNC_VERSION=3.0.1
RUN wget -q "https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb/download" -O turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get install -y -q ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   apt-get remove -y -q xfce4-screensaver && \
   rm ./turbovnc_${TURBOVNC_VERSION}_amd64.deb && \
   ln -s /opt/TurboVNC/bin/* /usr/local/bin/

# Install windows95
ARG WINDOWS95_VERSION=3.1.1
RUN wget -q "https://github.com/felixrieseberg/windows95/releases/download/v${WINDOWS95_VERSION}/windows95_${WINDOWS95_VERSION}_amd64.deb" && \
   apt-get install -y -q ./windows95_${WINDOWS95_VERSION}_amd64.deb && \
   rm ./windows95_${WINDOWS95_VERSION}_amd64.deb

# apt-get may result in root-owned directories/files under $HOME
RUN chown -R $NB_UID:$NB_GID $HOME

USER $NB_USER
RUN git clone --depth=1 https://github.com/jupyterhub/jupyter-remote-desktop-proxy && \
  cd jupyter-remote-desktop-proxy && \
  mamba env update -n base --file environment.yml

ADD --chown=$NB_UID:$NB_GID https://upload.wikimedia.org/wikipedia/commons/6/6d/Windows_Logo_%281992-2001%29.svg Pictures/Windows_Logo.svg
ADD --chown=$NB_UID:$NB_GID Windows_95.desktop Desktop/Windows_95.desktop
RUN mkdir -p .config/autostart && \
  ln -s $HOME/Desktop/Windows_95.desktop $HOME/.config/autostart/Windows_95.desktop
