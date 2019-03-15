#!/usr/bin/python

import os
import sys
import argparse
import subprocess

install_dir_fmt= '../_build-5.6-{0}'

cmake_debug= "cmake .. -DCMAKE_BUILD_TYPE=Debug -DWITH_SSL=system  -DMYSQL_MAINTAINER_MODE=1 -DENABLE_DTRACE=0 -DWITH_ZSTD=/usr "

cmake_release= "cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_SSL=system -DWITH_ZLIB=bundled -DWITH_LZ4=/usr/lib/x86_64-linux-gnu -DWITH_ZSTD=system -DWITH_JEMALLOC=/home/ubuntu/mysql-5.6/jemalloc/obj -DMYSQL_MAINTAINER_MODE=0 -DENABLED_LOCAL_INFILE=1 -DCMAKE_C_FLAGS=\"-DHAVE_JEMALLOC\" -DCMAKE_CXX_FLAGS=\"-march=native -DHAVE_JEMALLOC\" "# -DWITH_MYSQLD_LDFLAGS=\" -Wl,--whole-archive /home/ubuntu/mysql-5.6/jemalloc/lib/libjemalloc.a\" " 

parser= argparse.ArgumentParser()
parser.add_argument('--clean', action= 'store_true')
parser.add_argument('--release', action= 'store_true')
args= parser.parse_args()

def get_link_files():

  link_files = ['libmysqld/examples/CMakeFiles/mysqltest_embedded.dir/link.txt',
                'libmysqld/examples/CMakeFiles/mysql_embedded.dir/link.txt',
                'libmysqld/examples/CMakeFiles/mysql_client_test_embedded.dir/link.txt',
                'storage/rocksdb/unittest/CMakeFiles/test_properties_collector.dir/link.txt']

  link_lines= [] 
  for f in link_files:
    with open(f) as link_f:
      lines= link_f.read().splitlines() 
      assert(len(lines) == 1)
      lines[0] += ' -lpthread\n'
      link_lines.append([f, lines[0]])
      
  for f, l in link_lines:
    link_f= open(f, 'w')
    link_f.write(l)
    link_f.close()

if args.release:
  install_dir= install_dir_fmt.format("Release")
  cmake_cmd= cmake_release + "-DCMAKE_INSTALL_PREFIX=" + install_dir
else:
   install_dir= install_dir_fmt.format("Debug") 
   cmake_cmd= cmake_debug + "-DCMAKE_INSTALL_PREFIX=" + install_dir

print os.getcwd()

if args.clean:
  os.system('rm -rf build')
  os.system('mkdir build')
  os.chdir('build')
  os.system(cmake_cmd)
  get_link_files()
else:
  os.chdir('build')

os.system("make -j72 -Otarget && make install")


