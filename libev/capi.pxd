cdef extern from "ev.h":
    cdef struct ev_watcher:
        pass
    cdef struct ev_io:
        pass
    cdef struct ev_loop:
        pass

    # Global functions
    ev_loop* ev_loop_new(unsigned int)
    void ev_loop_destroy(ev_loop*)

    ev_loop* ev_default_loop(unsigned int)
    #ev_loop(ev_loop*, int)
    void ev_suspend(ev_loop*)
    void ev_resume(ev_loop*)
    void ev_unloop(ev_loop*, int)
    void ev_ref(ev_loop*)
    void ev_unref(ev_loop*)


    # Generic watcher stuff
    void ev_init(ev_watcher*, void*)

    # ev_io stuff
    ev_io_set(ev_io*, ...)
    ev_io_start(ev_loop*, ev_io*)
    ev_io_stop(ev_loop*, ev_io*)

    bint ev_is_active(ev_watcher*)
    bint ev_is_pending(ev_watcher*)
    void* ev_cb(ev_watcher*)
