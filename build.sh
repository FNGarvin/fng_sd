#!/bin/bash
#build our stable diffusion / cuda image - the bulk of this script is
#dedicated to allowing users to specify a read-only model directory and a writeable work directory

#if you want an external/existing directory of models mapped into your container (read-only), give
#the directory below.  This is useful because models can be HUGE and it's nice to be able to share 
#them among applications.  We expect the directory to have a models 
#subdirectory (eg, give the base of an existing webui)
AIDIR=~/ai  #set blank or comment out entirely otherwise

#it can be convenient to have a writeable directory mapped into the container, as well.  name a 
#directory below.  the installation will attempt to create this 
#directory if specified and will attempt to change group permissions as necessary to allow
#remapped GID write access inside container
#container does NOT write image outputs there by default, but it's possible 
#so long as you set up the bind at build-time.  Otherwise, requires a full rebuild
AIWORKDIR=./out 

#build volume argument
AIBUILDVARG=''
if [ -z "$AIDIR" ]; then 
	echo "building WITHOUT external model directory"
else 
	AIBUILDVARG="-v `realpath ${AIDIR}`:/run/media/ai:ro"
	echo "building WITH external model directory: '$AIBUILDVARG'"
fi

#setup the working directory
if [ -z "$AIWORKDIR" ]; then
	echo "building WITHOUT writeable work directory"
else
	#launch containers (use the commented versions, below, if you don't want/need mounts)
	#setup writeable, non-root bind ala https://www.redhat.com/en/blog/rootless-podman-makes-sense 
	mkdir -p "$AIWORKDIR"
	#choosing gid 1005 because that's what NVidia uses as vgluser in their images, ala
	#https://forums.developer.nvidia.com/t/using-nvidia-docker-containers-as-non-root-user/235252 
	podman unshare chown :1005 "$AIWORKDIR"
	#in case the user's normal umask doesn't include group access to the working directory we just created 
	chmod g+rwx "$AIWORKDIR"
	#update the volume argument with work directory:
	AIBUILDVARG="${AIBUILDVARG} -v `realpath ${AIWORKDIR}`:/run/media/out"
	echo "building WITH writeable working directory: '$AIBUILDVARG'"
fi

#now, finally build the container
echo "Beginning image build..."
podman build -t fng_sd $AIBUILDVARG .

#test
#echo podman run -d --name forge $AIBUILDVARG -p 7861:7861 --device nvidia.com/gpu=all --security-opt=label=disable fng_sd sleep infinity

#launch forge UI in a container named forge:
echo "Running forge container from fng_sd image"
echo podman run -d --name forge $AIBUILDVARG -p 7861:7861 --device nvidia.com/gpu=all --security-opt=label=disable fng_sd /home/ai/stable-diffusion-webui-forge/webui.sh

#launch Automatic1111 in a container named a1111:
#echo "Running a1111 container from fng_sd image"
#echo podman run -d --name a1111 $AIBUILDVARG -p 7860:7860 --device nvidia.com/gpu=all --security-opt=label=disable fng_sd /home/ai/stable-diffusion-webui/webui.sh
