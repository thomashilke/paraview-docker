# syntax=docker/dockerfile:1

# Ubuntu Jammy Jellyfish 22.04.1 LTS
FROM ubuntu:jammy AS builder

WORKDIR /

RUN apt-get update && apt-get install \
            git \
            cmake \
            build-essential \
            libgl1-mesa-dev \
            libxt-dev \
            qt5-default \
            libqt5x11extras5-dev \
            libqt5help5 \
            qttools5-dev \
            qtxmlpatterns5-dev-tools \
            libqt5svg5-dev \
            python3-dev \
            python3-numpy \
            libopenmpi-dev \
            libtbb-dev \
            ninja-build

RUN git clone --recursive https://gitlab.kitware.com/paraview/paraview.git \
    && mkdir /paraview_build

RUN cmake -GNinja \
          -DPARAVIEW_USE_PYTHON=ON \
          -DPARAVIEW_USE_MPI=ON \
          -DVTK_SMP_IMPLEMENTATION_TYPE=TBB \
          -DCMAKE_BUILD_TYPE=Release \
          -S paraview -B paraview_build

RUN cd /paraview_build \
    && ninja

RUN mkdir /paraview_install \
    && cd /paraview_build/ \
    && DESTDIR=/paraview_install/ ninja install \

FROM ubuntu:jammy

WORKDIR /

RUN apt-get update && apt-get install -y \
    libqt5help5 \
    libqt5opengl5 \
    libopengl0 \
    libpython3.10 \
    libtbb12 \
    libopenmpi3

COPY --from=builder /paraview_install/ /paraview_install/

RUN cp -r /paraview_install/usr/ / && rm -rf /paraview_install

ENTRYPOINT ["/usr/local/bin/paraview"]