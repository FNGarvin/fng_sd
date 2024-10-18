#until they come out w/ a 24.04 / 12.6+
FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

LABEL org.opencontainers.image.authors="184324400+FNGarvin@users.noreply.github.com"
LABEL description="Use AI to Create Images and Video with Stable Diffusion/ForgeUI/Automatic1111/ComfyUI"
#LABEL version="0.01"

#we'll use port 7860 for SD and 7861 for Forge
EXPOSE 7860
EXPOSE 7861

#install some packages
RUN apt update && apt install -y wget git python3 python3-venv libgl1 libglib2.0-0 libtcmalloc-minimal4 python3-pip sudo python-is-python3 dos2unix bc
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
#it's looking like it's, unfortunately, going to be more prudent to let each UI pick their own packages.
#too many moving parts with specific dependencies to justify the effort required just to save some few GB of download
#even just forcing pytorch w/ cuda 12.4 is a challenge...

#setup a user account ala https://forums.developer.nvidia.com/t/using-nvidia-docker-containers-as-non-root-user/235252 for vgluser trick on rootless NVidia
RUN groupadd -g 1005 vglusers && \
    useradd -ms /bin/bash ai -u 1000 -g 1005 && \
    usermod -a -G video,sudo ai
#set passwords for root and ai so sudo et al work
RUN printf "root:ai" | chpasswd
RUN printf "ai:ai" | chpasswd

USER ai

#clone a1111, forge ui, and comfyui up to the last version we've personally tested (June 2024)
#ENV GIT_TRACE_PACKET=1
#ENV GIT_TRACE=1
#ENV GIT_CURL_VERBOSE=1
RUN cd /home/ai && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui && cd stable-diffusion-webui && git checkout 82a973c04367123ae98bd9abdf80d9eda9b910e2
RUN cd /home/ai && git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git && cd stable-diffusion-webui-forge && git checkout 2c543719e34a82b5c48b60147f8bd97ffa91eb89
RUN cd /home/ai && git clone https://github.com/comfyanonymous/ComfyUI.git && cd ComfyUI && git checkout c695c4af7f78b5b8a37251b720ec48615ed28106

WORKDIR /run/media/ai/models
#make a symlink to each of the models for each webui:
RUN find -type d -exec mkdir --parents -- /home/ai/stable-diffusion-webui/models/{} \;
RUN find -type f -exec ln --symbolic -- /run/media/ai/models/{} /home/ai/stable-diffusion-webui/models/{} \;
RUN find -type d -exec mkdir --parents -- /home/ai/stable-diffusion-webui-forge/models/{} \;
RUN find -type f -exec ln --symbolic -- /run/media/ai/models/{} /home/ai/stable-diffusion-webui-forge/models/{} \;

#patch a111 for torch w/ cuda12.4 support (no longer needed as we are preinstalling torch outside of venv)
RUN sed -i 's/#export TORCH_COMMAND.*$/export TORCH_COMMAND=\"pip install torch torchvision --index-url https:\/\/download.pytorch.org\/whl\/cu124\"/g' /home/ai/stable-diffusion-webui/webui-user.sh
#patch forge and a11111's to use system python instead of venv (no need for containerception)
RUN sed -i 's/^#venv_dir=\"venv\"$/venv_dir=-/g' /home/ai/stable-diffusion-webui/webui-user.sh
RUN sed -i 's/^#venv_dir=\"venv\"$/venv_dir=-/g' /home/ai/stable-diffusion-webui-forge/webui-user.sh
#patch a1111 to accept LAN connections
RUN sed -i 's/^#export COMMANDLINE_ARGS=\"\"$/export COMMANDLINE_ARGS=\"--port 7860 --listen\"/g' /home/ai/stable-diffusion-webui/webui-user.sh
#patch forge to accept LAN connections on port 7861
RUN sed -i 's/^#export COMMANDLINE_ARGS=\"\"$/export COMMANDLINE_ARGS=\"--port 7861 --listen\"/g' /home/ai/stable-diffusion-webui-forge/webui-user.sh

#some convenience symlinks
WORKDIR /home/ai
RUN ln -s /run/media/ai /home/ai/ai
RUN ln -s /home/ai/stable-diffusion-webui /home/ai/sd
RUN ln -s /home/ai/stable-diffusion-webui-forge /home/ai/forge
RUN ln -s /home/ai/ComfyUI /home/ai/comfy
RUN ln -s /run/media/out /home/ai/out

#I think we need to leave this to the run stage so we can launch the correct app while still benefiting from a shared image w/ only one set of (large) downloads?
#ENTRYPOINT /home/ai/stable-diffusion-webui/webui.sh
#ENTRYPOINT "/bin/bash"
#ENTRYPOINT "sleep infinity"
