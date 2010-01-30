#!/usr/bin/python2.5

import libev as ev
import os
import sys

l = ev.Loop()

count = 0
STDIN = sys.stdin.fileno()
STDOUT = sys.stdout.fileno()

buf = []

def timer_cb(loop, watcher, revents):
    print '%r %r %r' % (loop, watcher, revents)

    print count, watcher.active

    watcher.set(count, 0)
    watcher.start(loop)
    count += 1

def stdin_cb(loop, watcher, revents):
    data = os.read(STDIN, 100)
    if data:
        print data,
    else:
        print 'stdin done !'
        si.stop()
        sys.exit()


#t = ev.Timer(timer_cb, 0, 0)
#t.start(l)

si = ev.IO(stdin_cb, STDIN, read=True)
si.start(l)

#so = ev.IO(stdout_cb, STDOUT, write=True)

l.loop()
