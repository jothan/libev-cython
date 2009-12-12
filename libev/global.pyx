cimport libev.capi as capi
cimport python_exc

@property
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

cdef class Loop:
    cdef capi.ev_lp* _c_loop

    def __cinit__(self, unsigned int flags=capi.EVFLAG_AUTO):
        self._c_loop = capi.ev_loop_new(flags)
        if self._c_loop is NULL:
            python_exc.PyErr_NoMemory()

    def __dealloc__(self):
        if self._c_loop is not NULL:
            capi.ev_loop_destroy(self._c_loop)

    def fork(self):
        capi.ev_loop_fork(self._c_loop)

    @property
    def is_default(self):
        return capi.ev_is_default_loop(self._c_loop)

    @property
    def count(self):
        return capi.ev_loop_count(self._c_loop)

    @property
    def depth(self):
        return capi.ev_loop_depth(self._c_loop)

    @property
    def backend(self):
        return capi.ev_backend(self._c_loop)

    @property
    def now(self):
        return capi.ev_now(self._c_loop)

    def now_update(self):
        capi.ev_now_update(self._c_loop)

    def suspend(self):
        capi.ev_suspend(self._c_loop)

    def resume(self):
        capi.ev_suspend(self._c_loop)

    def loop(self, int flags=0):
        capi.ev_loop(self._c_loop, flags)

    def unloop(self, bool all):
        capi.ev_unloop(self._c_loop, capi.EVUNLOOP_ALL if all else capi.EVUNLOOP_ONE)

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
