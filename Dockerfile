# https://ngc.nvidia.com/catalog/containers/nvidia:tensorrt
FROM nvcr.io/nvidia/tensorrt:21.12-py3
ARG DEBIAN_FRONTEND=noninteractive
# if you have 404 problems when you build the docker, try to run the upgrade
#RUN apt-get dist-upgrade -y
RUN apt-get -y update
# torch
RUN pip3 install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html
RUN pip install https://github.com/NVIDIA/Torch-TensorRT/releases/download/v1.0.0/torch_tensorrt-1.0.0-cp38-cp38-linux_x86_64.whl

# installing vapoursynth
RUN apt install ffmpeg autoconf libtool yasm python3.9 python3.9-venv python3.9-dev ffmsindex libffms2-4 libffms2-dev -y
RUN git clone https://github.com/sekrit-twc/zimg.git && cd zimg && ./autogen.sh && ./configure && make -j4 && make install && cd .. && rm -rf zimg
RUN pip install Cython
RUN git clone https://github.com/vapoursynth/vapoursynth.git && cd vapoursynth && ./autogen.sh && ./configure && make && make install && cd .. && ldconfig
RUN ln -s /usr/local/lib/python3.9/site-packages/vapoursynth.so /usr/lib/python3.9/lib-dynload/vapoursynth.so
RUN pip install vapoursynth

# onnx
RUN pip install onnx onnxruntime onnxruntime-gpu

# installing onnx tensorrt with a workaround, error with import otherwise
# https://github.com/onnx/onnx-tensorrt/issues/643
RUN git clone --depth 1 --branch 21.02 \
    https://github.com/onnx/onnx-tensorrt.git && \
    cd onnx-tensorrt && \
    cp -r onnx_tensorrt /usr/local/lib/python3.8/dist-packages && \
    cd .. && \
    rm -rf onnx-tensorrt

# downloading models
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/RealESRGANv2-animevideo-xsx2.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/RealESRGANv2-animevideo-xsx4.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/RealESRGAN_x4plus_anime_6B.pth -P /workspace
# fatal anime
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/4x_fatal_Anime_500000_G.pth -P /workspace
# rvp1
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/rvpV1_105661_G.pt -P /workspace
# sepconv
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/sepconv.pth -P /workspace
# EGVSR
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/EGVSR_iter420000.pth -P /workspace
# rife4 (fixed rife4.0 model)
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/rife40.pth -P /workspace
# RealBasicVSR_x4
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/RealBasicVSR_x4.pth -P /workspace
# cugan models
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up2x-latest-conservative.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up2x-latest-denoise1x.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up2x-latest-denoise2x.pth -P /workspace 
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up2x-latest-denoise3x.pth -P /workspace 
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up2x-latest-no-denoise.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up3x-latest-conservative.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up3x-latest-denoise3x.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up3x-latest-no-denoise.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up4x-latest-conservative.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up4x-latest-denoise3x.pth -P /workspace
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/up4x-latest-no-denoise.pth -P /workspace
# film
RUN wget https://github.com/styler00dollar/VSGAN-tensorrt-docker/releases/download/models/FILM.tar.gz -P /workspace
RUN cd /workspace && tar -zxvf FILM.tar.gz

# optional, rvp uses it to convert colorspace
RUN pip install kornia
# image read/write for image inference
RUN pip install opencv-python

# vs plugings from others
# https://github.com/HolyWu/vs-swinir
RUN pip install --upgrade vsswinir && python -m vsswinir
# https://github.com/HolyWu/vs-basicvsrpp
RUN pip install --upgrade vsbasicvsrpp && python -m vsbasicvsrpp

# dependencies for RealBasicVSR_x4
# mmedit
RUN git clone https://github.com/open-mmlab/mmediting.git && cd mmediting && pip install -v -e .
# RealBasicVSR_x4 will download this
RUN wget "https://download.pytorch.org/models/vgg19-dcbb9e9d.pth" -P /root/.cache/torch/hub/checkpoints/

# installing tensorflow because of FILM
RUN pip install tensorflow tensorflow-gpu tensorflow_addons gin-config -U

# misc
RUN pip install cupy-cuda115
RUN apt install x264 -y

# mpv
RUN apt install mpv -y
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes pulseaudio-utils
RUN apt-get install -y pulseaudio
RUN apt-get install pulseaudio libpulse-dev osspd -y