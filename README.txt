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
