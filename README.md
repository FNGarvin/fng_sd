# fng_sd

fng_sd aims to provide cutting-edge AI image generation tools in a package that's robust, secure, and suitable for people that would rather spend their time creating instead of tinkering. 

fng_sd currently consists of a Dockerfile that builds containers that run [Forge](https://github.com/lllyasviel/stable-diffusion-webui-forge), [Automatic1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui), and [Comfy UI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) along with an optional shell script to aid install and startup.  It is intended for use by users of relatively modern NVidia hardware and has built-in support for CUDA 12.4+.  The UIs ship bare-bones, but are fully capable of running all of the most popular generation models. 

## Prerequisites

fng_sd currently requires you to have an NVidia GPU with support for CUDA 12.4 and newer (NVIDIA GPUs from the G8x series onwards, including GeForce, Quadro, and the Tesla line).  Though if you are running something older/weaker than a 4GB GTX1650, you will be blazing a new trail on your own.  You must also have sufficiently recent drivers installed to support the same (dating to Summer 2024 or so).

You must also have support for running containers.  On Windows, this entails installing the [Windows Subsystem for Linux v2](https://learn.microsoft.com/en-us/windows/wsl/install) (basically, typing `wsl --install` from an administrative command prompt), followed by installing the NVidia Container Toolkit.  NVidia has instructions, [here](https://docs.nvidia.com/cuda/wsl-user-guide/index.html).  

Linux and Windows users will each need Podman (`sudo install podman`) or Docker Desktop.  I recommend and use Podman, though in practice it makes little difference.  Setting podman up to support CUDA requires a few [extra steps](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html).

When you get to the point that you can run `docker run --gpus all nvidia/cuda:11.5.2-base-ubuntu20.04 nvidia-smi -L` or `podman run --device nvidia.com/gpu=all --security-opt=label=disable nvidia/cuda:11.5.2-base-ubuntu20.04 nvidia-smi -L` and see something resembling running `nvidia-smi -L`, you should be all set.  It's not as hard to setup as the terse documents make it out to be - more detailed step-by-step instructions could perhaps be formulated if necessary.

### Project setup

Once you've got the prerequisites setup, it should be possible to download or clone the repository and run the build.sh script (`git clone https://github.com/FNGarvin/fng_sd.git && cd fng_sd && ./build.sh`).  It would be wise to review the build script before running it, however, as there are two options that merit invesigation regarding which directories you'd wish to allow the container access to.  More details to come, perhaps. 

### Project configuration

Once you've got the container up and running, most of your interaction will be done through a web browser.  Forge would be a good place to start, [on port 7861](http://localhost:7861).  But it's certainly possible to spawn a bash shell into the container, allowing more advanced control.

## Troubleshootings

As of now, this project has one user.  I expect this section to grow (or stagnate) with the user base.

## Authors & Maintainers

All credit goes to NVidia, PyTorch, lllyasviel, anonymouscomfy, and the rest of the AI community.  This project is just a tiny bit of glue attempting to package the best of what's out there into something accessible and sufficiently insulated to take some of the risk out of running untrusted code.

## Contributing

Contributions, issues and feature requests are welcome!

Feel free to check [issues page](https://github.com/fngarvin/fng_sd/issues).

