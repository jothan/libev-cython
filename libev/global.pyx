cimport libev.capi as capi
cimport python_exc
import math
import sys

__all__ = ['time', 'sleep', 'version_major', 'version_minor', 'version',
           'supported_backends', 'embeddable_backends',
           'Loop', 'IO', 'Timer']

def time():
    return capi.ev_time()

def sleep(capi.ev_tstamp t):
    capi.ev_sleep(t)

def version_major():
    return capi.ev_version_major()

def version_minor():
    return capi.ev_version_minor()

def version():
    return (capi.ev_version_major(),
            capi.ev_version_minor())

def supported_backends():
    return _backend_mask_to_set(capi.ev_supported_backends())

def recommended_backends():
    return _backend_mask_to_set(capi.ev_recommended_backends())

def embeddable_backends():
    return _backend_mask_to_set(capi.ev_embeddable_backends())

_bid_to_name = {
    capi.EVBACKEND_SELECT: 'select',
    # POLL is somehow broken
    #capi.EVBACKEND_POLL: 'poll',
    capi.EVBACKEND_EPOLL: 'epoll',
    capi.EVBACKEND_KQUEUE: 'kqueue',
    capi.EVBACKEND_DEVPOLL: 'devpoll',
    capi.EVBACKEND_PORT: 'port',
}

cdef _backend_mask_to_set(unsigned int backends):
    res = []

    for exp in xrange(0, int(math.log(backends, 2)+1)):
        idx = 2**exp
        name = _bid_to_name.get(idx, idx)
        res.append(name)

    return frozenset(res)


cdef class Loop(object):
    cdef capi.ev_lp* _c_loop
    cdef object _pending_exc

    def __init__(self, *args, **kw):
        self._pending_exc = []

    def __cinit__(self, unsigned int flags=capi.EVFLAG_AUTO):
        self._c_loop = capi.ev_loop_new(flags)
        if self._c_loop is NULL:
            python_exc.PyErr_NoMemory()

    def __dealloc__(self):
        if self._c_loop is not NULL:
            capi.ev_loop_destroy(self._c_loop)

    def fork(self):
        capi.ev_loop_fork(self._c_loop)

    property is_default:
        def __get__(self):
            return capi.ev_is_default_loop(self._c_loop)

    property count:
        def __get__(self):
            return capi.ev_loop_count(self._c_loop)

    property depth:
        def __get__(self):
            return capi.ev_loop_depth(self._c_loop)

    property backend:
        def __get__(self):
            back = capi.ev_backend(self._c_loop)
            return _bid_to_name.get(back, back)

    property now:
        def __get__(self):
            return capi.ev_now(self._c_loop)

    def now_update(self):
        capi.ev_now_update(self._c_loop)

    def suspend(self):
        capi.ev_suspend(self._c_loop)

    def resume(self):
        capi.ev_suspend(self._c_loop)

    def loop(self, bool once=False, bool block=True):
        cdef int flags = capi.EVLOOP_ONESHOT

        if not block:
            flags |= capi.EVLOOP_NONBLOCK

        while True:
            if self._pending_exc:
                exc_info = self._pending_exc.pop()
                raise exc_info[0], exc_info[1], exc_info[2]

            capi.ev_loop(self._c_loop, flags)

            if once:
                break

    def unloop(self, bool all=True):
        capi.ev_unloop(self._c_loop, capi.EVUNLOOP_ALL if all else capi.EVUNLOOP_ONE)

    def _exc(self, exc_info):
        self._pending_exc.append(exc_info)
        self.unloop(all=False)

    def ref(self):
        capi.ev_ref(self._c_loop)

    def unref(self):
        capi.ev_unref(self._c_loop)

    # TODO as properties
    #ev_set_io_collect_interval(loop, ev_tstamp interval)
    #ev_set_timeout_collect_interval(loop, ev_tstamp interval)

    def invoke_pending(self):
        capi.ev_invoke_pending(self._c_loop)

    @property
    def pending_count(self):
        return capi.ev_pending_count(self._c_loop)

    # TODO
    #ev_set_invoke_pending_cb (loop, void (*invoke_pending_cb)(EV_P))
    #ev_set_loop_release_cb (loop, void (*release)(EV_P), void (*acquire)(EV_P))

    # Is there any point to these ?
    #ev_set_userdata (loop, void *data)
    #ev_userdata (loop)

    def verify(self):
        capi.ev_loop_verify(self._c_loop)

cdef void _callback(capi.ev_lp* lp, capi.ev_watcher* cwatcher, int revents):
    watcher = <Watcher>cwatcher.data
    loop = watcher._loop
    #assert <capi.ev_lp*>(watcher._loop._ptr()) == lp
    try:
        watcher._callback(loop, watcher, revents)
    except:
        loop._exc(sys.exc_info())

cdef class Watcher(object):
    cdef public Loop _loop
    cdef public object _callback
    cdef capi.ev_watcher* _watcher

    def __cinit__(Watcher self, *args, **kw):
        self._watcher = <capi.ev_watcher*>capi.malloc(self._alloc())
        if self._watcher is NULL:
            python_exc.PyErr_NoMemory()
        self._watcher.data = <void*>self

    def __dealloc__(self):
        if self._watcher is not NULL:
            self.stop()
            capi.free(self._watcher)
            self._watcher = NULL

    def __init__(self, cb, *args, **kw):
        self._loop = None
        capi.ev_init(self._watcher, _callback)
        self._callback = cb
        self._set(*args, **kw)

    cpdef start(self, loop):
        if self._loop is not None and loop is not self._loop:
            raise ValueError('Watchers can only be used with one loop at a time')

        self._loop = loop
        self._start(loop)

    cpdef stop(self):
        self._stop()
        self._loop = None

    def set(self, *args, **kw):
        cdef bool was_active = self.active
        cdef Loop loop = self._loop

        if was_active:
            self.stop()

        self._set(*args, **kw)

        if was_active:
            self.start(loop)

    property active:
        def __get__(self):
            return capi.ev_is_active(self._watcher)

cdef class Timer(Watcher):
    def _alloc(self):
        return sizeof(capi.ev_timer)

    cpdef _set(self, capi.ev_tstamp after, capi.ev_tstamp repeat):
        capi.ev_timer_set(<capi.ev_timer*>self._watcher, after, repeat)

    cpdef _start(self, Loop loop):
        capi.ev_timer_start(loop._c_loop, <capi.ev_timer*>self._watcher)

    cpdef _stop(self):
        capi.ev_timer_stop(self._loop._c_loop, <capi.ev_timer*>self._watcher)

cdef class IO(Watcher):
    def _alloc(self):
        return sizeof(capi.ev_io)

    cpdef _set(self, int fd, read=False, write=False):
        cdef int flags = 0

        if not (read or write):
            raise ValueError('IO watcher must watch for read and/or write')

        if read:
            flags |= capi.EV_READ

        if write:
            flags |= capi.EV_WRITE

        capi.ev_io_set(<capi.ev_io*>self._watcher, fd, flags)

    cpdef _start(self, Loop loop):
        capi.ev_io_start(loop._c_loop, <capi.ev_io*>self._watcher)

    cpdef _stop(self):
        capi.ev_io_stop(self._loop._c_loop, <capi.ev_io*>self._watcher)

    property fd:
        def __get__(self):
            return (<capi.ev_io*>self._watcher).fd

    property events:
        def __get__(self):
            return (<capi.ev_io*>self._watcher).events
