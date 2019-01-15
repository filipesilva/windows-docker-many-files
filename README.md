# Building Windows docker images with many files is much slower than on Linux images

This is a reproduction of how Windows Docker containers is slow to build images with many small files when compared to Linux containers.
The cost of creating a file on Windows seems to be up to 7x than on Linux. 
This time is not spend in the build step proper, but rather after the build step, in Docker operations.

As mentioned in [this github comment about slow builds](https://github.com/docker/for-win/issues/1936#issuecomment-380257581) and [the official docker page about antivirus](https://docs.docker.com/engine/security/antivirus/), disabling Windows Defender for docker folders helps cut this cost by about half, but it's still slow. 

You can see see docker file access and Windows defender scanning those files with https://docs.microsoft.com/en-us/sysinternals/downloads/procmon.
To exclude the docker folder in a admin Powershell run `Set-MpPreference -ExclusionPath $Env:ProgramData'\Docker', '\Device\'`.

This slowness can be seen mainly in between the build steps, I assume due to adding the files to the new layer. 
At this point `docker ps -a` reports no container is actually up.

To show this I used Node dependencies, because they are what I work with everyday and known for having lots of small files.

For a small dependency set the time is already 3 to 7 times longer in Windows than in Linux containers:

Linux:
- command: `time docker build --no-cache --build-arg FROM="node:10.11" .`
- reported dependency install step time: ~12 seconds
- docker build total time: ~28 seconds

Windows:
- command: `time docker build --no-cache --build-arg FROM="stefanscherer/node-windows:10.11" .`
- reported dependency install step time: ~17 seconds
- docker build total time: ~220 seconds
- docker build total time with windows defender exclusions: ~99 seconds

The relative time difference seems to be maintained for larger dependency sets too:

Linux:
- command: `time docker build --no-cache --build-arg FROM="node:10.11" --build-arg PACKAGE_JSON="large-package.json" .`
- reported dependency install step time: ~86 seconds
- docker build total time: ~140 seconds

Windows:
- command: `time docker build --no-cache --build-arg FROM="stefanscherer/node-windows:10.11" --build-arg PACKAGE_JSON="large-package.json" .`
- reported dependency install step time: ~112 seconds
- docker build total time: ~1080 seconds (18 minutes)
- docker build total time with windows defender exclusions: ~465 seconds (7 minutes 45 seconds)

Relevant system information:
- Docker Desktop Community v2.0.2 (30215)
- Windows 10 1809
- i7-8650U, 16GB RAM, 1TB PCIe-NVM SSD
- Using gitbash as console for the `time` command