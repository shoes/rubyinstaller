This is a fork of the main RubyInstaller project for the purposes of
getting Shoes to build. Shoes maintains an entire environment of its
own including the Ruby interpreter. The RubyInstaller project already
provides an excellent set of tools and recipes for building the
complex Ruby project, so it's a natural fit for also building Shoes.

To build, first install MRI 1.9.2 using the downloadable RubyInstaller
from rubyinstaller.org. Then, using git, clone this repository.

=== Build Task Examples:

rake                             # builds Shoes [default build task]
rake shoes                       # same
rake --trace                     # verbose output of everything it is doing


== How To Help

Welcome, RubyConf!

We would love some help in getting Shoes working on Windows. To reproduce the latest environment, follow the steps below.

# Assumes you have a working Ruby on your system + git

1. git clone git://github.com/shoes/rubyinstaller.git

2. cd rubyinstaller

3. rake ruby19 # necessary so certain libs are available to Shoes later on

4. rake shoes

Step 4 will clone my personal fork of shoes (https://github.com/chuckremes/shoes) where I made a bunch of changes to support the new directory structure created by RubyInstaller (the sandbox and its descendents). Everything should compile cleanly. If "rake ruby19" generates errors, try removing the entire sandbox (and its subdirs) and try again.

The shoes.exe and all related files are created in ~\rubyinstaller\sandbox\shoes\dist. You'll have to manually copy in libfontconfig-1.dll, freetype6.dll, libpng14-14.dll and libexpat-1.dll to that directory to satisfy all dependencies. I'll fix up the rake file to do that automatically soon. I recommend getting these DLLs from a working install of Shoes (http://github.com/downloads/shoes/shoes/shoes3-novideo.exe.zip) so that the versions match up; if you get these DLLs from other sources, the APIs might have changed.

Double-clicking (or running it from the command-line) the shoes.exe should launch, but it doesn't. Expect an error along the lines of "\path\to\exe is not a valid win32 application." Help!
