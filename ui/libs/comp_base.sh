set -xe 
gcc -o base base.c plib3.c
./base -gx=1 -gy=1 -wr=1 -wc=1 -fs=1 -- foo bar
