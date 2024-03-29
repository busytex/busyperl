#2020-11-29T00:24:34.8505712Z warning: undefined symbol: __stack_chk_fail (referenced by top-level compiled C/C++ code)
#2020-11-29T00:24:34.8573524Z warning: undefined symbol: sigsuspend (referenced by top-level compiled C/C++ code)

# ##### WebPerl - http://webperl.zero-g.net #####
# 
# Copyright (c) 2018 Hauke Daempfling (haukex@zero-g.net)
# at the Leibniz Institute of Freshwater Ecology and Inland Fisheries (IGB),
# Berlin, Germany, http://www.igb-berlin.de
# 
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl 5 itself: either the GNU General Public
# License as published by the Free Software Foundation (either version 1,
# or, at your option, any later version), or the "Artistic License" which
# comes with Perl 5.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the licenses for details.
# 
# You should have received a copy of the licenses along with this program.
# If not, see http://perldoc.perl.org/index-licence.html


osname="emscripten"
archname="wasm"
osvers="2.0.5"

myhostname='localhost'
mydomain='.local'
cf_email='haukex@zero-g.net'
perladmin='root@localhost'

#TODO: almost all of the known_extensions are still being built. we should probably exclude some of them! (see also nonxs_ext)
# [arybase attributes B Compress/Raw/Bzip2 Compress/Raw/Zlib Cwd Data/Dumper
# Devel/Peek Devel/PPPort Digest/MD5 Digest/SHA Encode Fcntl File/DosGlob
# File/Glob Filter/Util/Call Hash/Util Hash/Util/FieldHash I18N/Langinfo IO
# List/Util Math/BigInt/FastCalc MIME/Base64 mro Opcode PerlIO/encoding
# PerlIO/mmap PerlIO/scalar PerlIO/via POSIX re SDBM_File Socket Storable
# Sys/Hostname Sys/Syslog threads threads/shared Tie/Hash/NamedCapture
# Time/HiRes Time/Piece Unicode/Collate Unicode/Normalize XS/APItest XS/Typemap]  
#TODO Later: Reinsert Storable after Socket, its Makefile seems to not work in our environment
static_ext="attributes B Cwd Data/Dumper Devel/Peek Digest/MD5 Digest/SHA Encode Fcntl File/Glob Hash/Util I18N/Langinfo IO List/Util mro Opcode PerlIO/encoding PerlIO/scalar PerlIO/via POSIX re SDBM_File Socket Tie/Hash/NamedCapture Time/HiRes Time/Piece Unicode/Normalize"
dynamic_ext=''
noextensions='IPC/SysV'

cc="emcc"
ld="emcc"

#nm="`which llvm-nm`"  # note from Glossary: 'After Configure runs, the value is reset to a plain "nm" and is not useful.'
ar="`which emar`"  # note from Glossary: 'After Configure runs, the value is reset to a plain "ar" and is not useful.'
ranlib="`which emranlib`"

# Here's a fun one: apparently, when building perlmini.c, emcc notices that it's a symlink to perl.c, and compiles to perl.o
# (because there is no -o option), so the final perl ends up thinking it's miniperl (shown in "perl -v", @INC doesn't work, etc.).
# Because of this and other issues I've had with symlinks, I'm switching to hard links instead.
# (Another possible fix might be to fix the Makefile steps so that they use the -o option, but this solution works for now.)
#TODO Later: In NODEFS, does Perl's -e test work correctly on symlinks? (./t/TEST was having issues detecting ./t/perl, a symlink to ./perl).
lns="/bin/ln"

prefix="/opt/perl"
inc_version_list="none"

man1dir="none"
man3dir="none"

loclibpth=''
glibpth=''

usemymalloc="n"
uselargefiles="n"
usenm='undef'

usemallocwrap="define"
d_procselfexe='undef'
d_dlopen='undef'
dlsrc='none'
d_getgrgid_r='define'
d_getgrnam_r='define'
d_libname_unique="define"
d_getnameinfo='define'

d_setrgid='undef'
d_setruid='undef'
d_setproctitle='undef'
d_malloc_size='undef'
d_malloc_good_size='undef'
d_fdclose='undef'

#d_prctl='define' # hm, it's present in the libc source, but Configure shows Emscripten error output? -> for now, assume it's not available

# It *looks* like shm*, sem* and a few others exist in Emscripten's libc,
# but I'm not sure why Configure isn't detecting them. But at the moment I'm not going
# to worry about them, and just not build IPC-SysV.
d_clearenv='undef'
d_cuserid='undef'
d_eaccess='undef'
d_getspnam='undef'
d_msgctl='undef'
d_msgget='undef'
d_msgrcv='undef'
d_msgsnd='undef'
d_semget='undef'
d_semop='undef'
d_shmat='undef'
d_shmctl='undef'
d_shmdt='undef'
d_shmget='undef'
d_syscall='undef'


# Emscripten does not have signals support (documentation isn't 100% clear on this? but see "$EMSCRIPTEN/system/include/libc/setjmp.h")
# but if you do: grep -r 'Calling stub instead of' "$EMSCRIPTEN"
# you'll see the unsupported stuff (as of 1.37.35):
# signal() sigaction() sigprocmask() __libc_current_sigrtmin __libc_current_sigrtmax kill() killpg() siginterrupt() raise() pause()
# plus: "Calling longjmp() instead of siglongjmp()"
d_sigaction='undef'
d_sigprocmask='undef'
d_killpg='undef'
d_pause='undef'
d_sigsetjmp='undef' # this also disables Perl's use of siglongjmp() (see config.h)
# the others either aren't used by Perl (like siginterrupt) or can't be Configure'd (like kill)
#TODO Later: currently I've disabled Perl's use of signal() by patching the source - maybe there's a better way?

# Emscripten doesn't actually have these either (see "$EMSCRIPTEN/src/library.js")
d_wait4='undef'
d_waitpid='undef'
d_fork='define' # BUT, perl needs this one to at least build
d_vfork='undef'
d_pseudofork='undef'

i_pthread='undef'
d_pthread_atfork='undef'
d_pthread_attr_setscope='undef'
d_pthread_yield='undef'

# We're avoiding all the 64-bit stuff for now.
# Commented out stuff is correctly detected.
#TODO: JavaScript uses 64-bit IEEE double FP numbers - will Perl use those?
#TODO: Now that we've switched to WebAssembly, can we use 64 bits everywhere?
# see https://groups.google.com/forum/#!topic/emscripten-discuss/nWmO3gi8_Jg
#use64bitall='undef'
#use64bitint='undef'
#usemorebits='undef'
#usequadmath='undef'
#TODO Later: Why does Configure seem to ignore the following? (and do we care?)
d_quad='undef'

#TODO Later: The test for "selectminbits" seems to fail,
# the error appears to be coming from this line (because apparently stream.stream_ops is undefined):
# https://github.com/kripken/emscripten/blob/ddfc3e32f65/src/library_syscall.js#L750
# For now, just use this number from a build with an earlier version where this didn't fail:
selectminbits='32'
alignbytes='4'


optimize="-O2"


ldflags="$ldflags -lm -O2 -s NO_EXIT_RUNTIME=1 -s ALLOW_MEMORY_GROWTH=1 -Wno-almost-asm"
ldflags="$ldflags -s ERROR_ON_UNDEFINED_SYMBOLS=0 -s WASM=1"

# the following is needed for the "musl" libc provided by emscripten to provide all functions
ccflags="$ccflags -D_GNU_SOURCE -D_POSIX_C_SOURCE"
# from Makefile.emcc / Makefile.micro
ccflags="$ccflags -DSTANDARD_C -DPERL_USE_SAFE_PUTENV -DNO_MATHOMS"
# disable this warning, I don't think we need it - TODO: how to append this after -Wall?
ccflags="$ccflags -Wno-null-pointer-arithmetic"


# Configure apparently changes "-s ASSERTIONS=2 -s STACK_OVERFLOW_CHECK=2" to "-s -s" when converting ccflags to cppflags
# this is the current hack/workaround: copy cppflags from config.sh and fix it (TODO Later: better way would be to patch Configure)
cppflags='-lm -s ERROR_ON_UNDEFINED_SYMBOLS=0 -D_GNU_SOURCE -D_POSIX_C_SOURCE -DSTANDARD_C -DPERL_USE_SAFE_PUTENV -DNO_MATHOMS -Wno-null-pointer-arithmetic -fno-strict-aliasing -pipe -fstack-protector-strong -I/usr/local/include'

libs='-lm'
