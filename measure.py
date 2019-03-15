#!/usr/bin/python

import os 
import sys
import subprocess
import time
import argparse

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--config')
  parser.add_argument('--duration')
  parser.add_argument('--interval')
  parser.add_argument('--output')
  args = parser.parse_args()

  assert(args.config and args.duration and args.interval and args.output)

  config_file = args.config
  duration = int(args.duration)
  interval = int(args.interval)
  output_file = args.output
  return config_file, duration, interval, output_file

def measure(config_file, duration, interval, output_file):
  top_dir = '_build-5.6-Release/'
  os.chdir(top_dir)

  cmd_fmt = './bin/mysqladmin --defaults-file={0} extended-status'
  cmd = cmd_fmt.format(config_file).split() 

  commit_counts = []
  sched_counts = []
  wait_counts= []

  for i in range(0, duration, interval):
    lines= subprocess.check_output(cmd).splitlines()
    commit_counts.append(com_commit_count(lines))
    if config_file == 'slave.cnf':
      sched_counts.append(scheduled_count(lines))
      wait_counts.append(next_event_waits(lines))
    time.sleep(interval)

  outfile = open(output_file, 'w')
  for c in commit_counts:
    outfile.write(str(c) + '\n')
  outfile.close()

  if config_file == 'slave.cnf':
    prodfile = open('producer.out', 'w')
    for c in sched_counts:
      prodfile.write(str(c) + '\n')
    prodfile.close()

    waitfile= open('next_waits.out', 'w')
    for w in wait_counts:
      waitfile.write(str(w) + '\n')
    waitfile.close()

def scheduled_count(lines):
  sched_count= ''
  for l in lines:
    if l.startswith('| Slave_producer_scheduled'):
      sched_count= l
      break
  return int(filter(lambda x: x != '|', sched_count.split())[1])

def com_commit_count(lines):
  commit_count= ''
  for l in lines:
    if l.startswith('| Com_commit'):
      commit_count= l
      break
  return int(filter(lambda x: x != '|', commit_count.split())[1])
 
def next_event_waits(lines):
  wait_count= ''
  for l in lines:
    if l.startswith('| Slave_dependency_next_waits'):
      wait_count= l
      break
  return int(filter(lambda x: x != '|', wait_count.split())[1])

def main():
  config_file, duration, interval, output_file = parse_args()
  measure(config_file, duration, interval, output_file)

if __name__ == "__main__":
  main()
