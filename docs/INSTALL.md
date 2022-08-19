# Installation instructions

This install document starts from zero-point five day, as if you already have Docker Desktop, and have enabled WSL 2 on your system

## Setting up the WSL 2 system

Please note that this should be done from a fresh WSL 2 distrobution.

**Ubuntu is absolutely required due to tensorflow-gpu support restrictions with the NVIDIA Cuda/CuDUNN drivers.  Believe you me, I tried debian to get away from Ubuntu, but it was a headache and a half, and I ended up running into some crazy llvm errors.  Just avoid any other distro for full WSL GPU support.**

To make a fresh distribution, you can run (In Administrator Windows PowerShell):

```ps1
<# to install the environment, and setup your username #>
wsl --install -d Ubuntu-20.04

<# to enter the environment #>
wsl -d Ubuntu-20.04 -u your_username
```

## Running WSL 2 on another drive

After you've closed out of WSL's window that appears when running the ``wsl --install`` command, you can copy it to another drive to save space on your disk, like this:

```ps1
mkdir D:\wsl
cd D:\wsl
wsl --export -d Ubuntu-20.04 D:\wsl\Ubuntu-20.04.tar
wsl --unregister -d Ubuntu-20.04
wsl --import Ubuntu-20.04 Ubuntu-20.04.tar .\Ubuntu-20.04r
```

## Copying the install scripts

Provided you've followed the instructions to get yourself a fresh WSL 2 on a different disk, Linux should become available in File Explorer if it already isn't.  You can copy the repository contents into your ``/home`` directory.

```ps1
cd C:\where\you\downloaded\this\repo\
Move-Item -Resource -Force .\* \\wsl.localhost\Ubuntu-20.04\\home\
```

Now you can go ahead and move back into your WSL2 instance:

```ps1
wsl -d Ubuntu-20.04 -u your_username
```

## Configure it.

You need to run ``nano ~/xx-github.sh`` to set up credential to login to github.  THIS IS REQURIED.  Reason:  git use in docker for some of the build steps, general best-practices.

**Optional**:  Run ``nano ~/xx-vars.sh`` if you want to insepct some things or change them.

> Hey editor wars people, I don't care.  Don't MPR my README because I didn't use vim in my installer manual.  Thanks!

Your own installer chain could hook onto mine and customize it by modifying both of these files!  I have accounted for this situation with some very particular system checks and conditional code.  You're welcome.

## Run it.

Here you go, Mr. or Mrs. Copy-paste:

```
cd ~/
chmod +x ./*-*.sh
./99-install-tensorflow.sh
```

You'll now have tensorflow (in a few hours)  Go get a coffee or something.  This is that wait-it-while-i-bake-it step you should all be familiar with if you happened upon GentooDAD back in the day.  :-)

## Enjoy.

I haven't put this piece in the manual yet, because I've not finished testing.  But thanks for reading.  I got really tired of typing documentation, so I'll replace this later on!
