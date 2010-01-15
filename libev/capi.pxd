cdef extern from "stdlib.h":
     void free(void *ptr)
     void *malloc(size_t size)
     void *realloc(void *ptr, size_t size)

cdef extern from "ev.h":
    cdef struct ev_watcher:
        void *data

    cdef struct ev_io:
        void *data

    cdef struct ev_timer:
        void *data

    # If we use struct ev_loop here, we get a big fat name collision
    # with the ev_loop function.
    ctypedef struct ev_lp:
        pass

    ctypedef double ev_tstamp
    ctypedef void CB_TYPE(ev_lp*, ev_watcher*, int)

    unsigned int EVFLAG_AUTO
    unsigned int EVFLAG_NOENV
    unsigned int EVFLAG_FORKCHECK
    unsigned int EVFLAG_NOINOTIFY
    unsigned int EVFLAG_NOSIGFD
    unsigned int EVBACKEND_SELECT
    unsigned int EVBACKEND_POLL
    unsigned int EVBACKEND_EPOLL
    unsigned int EVBACKEND_KQUEUE
    unsigned int EVBACKEND_DEVPOLL
    unsigned int EVBACKEND_PORT
    unsigned int EVBACKEND_ALL
    unsigned int EVUNLOOP_ONE
    unsigned int EVUNLOOP_ALL
    unsigned int EVLOOP_NONBLOCK
    unsigned int EVLOOP_ONESHOT
    unsigned int EV_READ
    unsigned int EV_WRITE

    # Global functions
    ev_tstamp ev_time()
    void ev_sleep(ev_tstamp)
    int ev_version_major()
    int ev_version_minor()
    unsigned int ev_supported_backends()
    unsigned int ev_recommended_backends()
    unsigned int ev_embeddable_backends()

    ev_lp* ev_loop_new(unsigned int)
    void ev_loop_destroy(ev_lp*)

    # loop methods
    void ev_loop_fork(ev_lp*)
    bint ev_is_default_loop(ev_lp*)
    unsigned int ev_loop_count(ev_lp*)
    unsigned int ev_loop_depth(ev_lp*)
    unsigned int ev_backend(ev_lp*)
    ev_tstamp ev_now(ev_lp*)
    void ev_now_update(ev_lp*)
    void ev_suspend(ev_lp*)
    void ev_resume(ev_lp*)
    void ev_loop(ev_lp*, int)
    void ev_unloop(ev_lp*, int)
    void ev_ref(ev_lp*)
    void ev_unref(ev_lp*)
    void ev_set_io_collect_interval(ev_lp*, ev_tstamp)
    void ev_set_timeout_collect_interval(ev_lp*, ev_tstamp)
    void ev_invoke_pending(ev_lp*)
    int ev_pending_count(ev_lp*)

    # TODO
    #ev_set_invoke_pending_cb (loop, void (*invoke_pending_cb)(EV_P))
    #ev_set_loop_release_cb (loop, void (*release)(EV_P), void (*acquire)(EV_P))

    # Is there any point to these ?
    #ev_set_userdata (loop, void *data)
    #ev_userdata (loop)

    void ev_loop_verify(ev_lp*)

    # Generic watcher stuff
    void ev_init(ev_watcher*, CB_TYPE*)

    # ev_io stuff
    void ev_io_set(ev_io*, int, int)
    void ev_io_start(ev_lp*, ev_io*)
    void ev_io_stop(ev_lp*, ev_io*)

    # ev_timer stuff
    void ev_timer_set(ev_timer*, ev_tstamp, ev_tstamp)
    void ev_timer_start(ev_lp*, ev_timer*)
    void ev_timer_stop(ev_lp*, ev_timer*)
    void ev_timer_again(ev_lp*, ev_timer*)
    ev_tstamp ev_timer_remaining(ev_lp*, ev_timer*)


    bint ev_is_active(ev_watcher*)
    bint ev_is_pending(ev_watcher*)
    void* ev_cb(ev_watcher*)
