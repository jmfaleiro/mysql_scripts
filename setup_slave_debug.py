#!/usr/bin/python

import os 
import sys
import subprocess
import time
import argparse

def parse_args():
  parser= argparse.ArgumentParser()
  parser.add_argument('--master')
  parser.add_argument('--logfile')
  parser.add_argument('--logpos')
  args= parser.parse_args()

  assert(args.master and args.logfile and args.logpos)

  print 'Master: ' + args.master
  print 'LogFile: ' + args.logfile
  print 'LogPos: ' + args.logpos

  return args.master, args.logfile, args.logpos

def setup_configs(dest_dir):
  cur_parent_dir = os.path.dirname(os.getcwd())
  config_parent_dir = os.path.join(cur_parent_dir, "mysql_scripts", "configs")
  config_files = os.listdir(config_parent_dir)
  for f in config_files:
    os.system("cp " + os.path.join(config_parent_dir, f) + " " + dest_dir)

def setup_slave(master, logfile, logpos):
  top_dir = "_build-5.6-Debug/"
  slave_dir = "data/mysqld.2/"
  setup_configs(top_dir)
  os.chdir(top_dir)


  master_change_fmt= "change master to master_host=\'{0}\', master_port=3306, master_user=\'root\', master_log_file=\'{1}\', master_log_pos={2};" 

  os.system("scripts/mysql_install_db --defaults-file=slave.cnf --force")
  subprocess.Popen(['bin/mysqld', '--defaults-file=slave.cnf', '--skip-slave-start'], 
                   cwd= '.',
                   stdout= subprocess.PIPE,
                   stderr= subprocess.STDOUT)
  while True:
    if os.path.exists("data/mysqld.2/mysqld.2.sock"):
      break

  time.sleep(1)

  os.system("bin/mysql --defaults-file=slave.cnf < master.dump")
  master_change_str= master_change_fmt.format(master, logfile, logpos)
  os.system("bin/mysql --defaults-file=slave.cnf -e \" "+ master_change_str + "\";")
  os.system("bin/mysql --defaults-file=slave.cnf -e \"start slave;\" ")
  # os.system("bin/mysql --defaults-file=slave.cnf < setup_slave")

def main():
  master, logfile, logpos = parse_args()
  setup_slave(master, logfile, logpos)

if __name__ == "__main__":
  main()
