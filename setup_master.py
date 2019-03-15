#!/usr/bin/python

import os 
import sys
import subprocess
import time
import argparse

def setup_configs(dest_dir):
  cur_parent_dir = os.path.dirname(os.getcwd())
  config_parent_dir = os.path.join(cur_parent_dir, "mysql_scripts", "configs")
  config_files = os.listdir(config_parent_dir)
  for f in config_files:
    os.system("cp " + os.path.join(config_parent_dir, f) + " " + dest_dir)

def setup_master():
  top_dir= "_build-5.6-Release/"
  master_dir= "data/mysqld.1/"

  setup_configs(top_dir)
  os.chdir(top_dir)
  os.system("scripts/mysql_install_db --defaults-file=master.cnf --force")

  subprocess.Popen(['bin/mysqld', '--defaults-file=master.cnf'], 
                   cwd= '.',
                   stdout= subprocess.PIPE,
                   stderr= subprocess.STDOUT)

  while True:
    if os.path.exists("data/mysqld.1/mysqld.1.sock"):
      break

  time.sleep(5)

  os.system("bin/mysql --defaults-file=master.cnf < setup_master")
  os.system("bin/mysql --defaults-file=master.cnf < master_log_pos > log_pos_out")
  os.system("bin/mysqldump --defaults-file=master.cnf --all-databases > master.dump")
  os.system("bin/mysql --defaults-file=master.cnf -e \"unlock tables\"")

def main():
  setup_master()

if __name__ == "__main__":
  main() 
