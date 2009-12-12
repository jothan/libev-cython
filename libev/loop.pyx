cimport libev.capi as capi
cimport python_exc

cdef class Loop:
    cdef capi.ev_loop* _c_loop

    def __cinit__(self):
        self._c_loop = capi.ev_loop_new(0)
        if self._c_loop is NULL:
            python_exc.PyErr_NoMemory()

    def __dealloc__(self):
        if self._c_loop is not NULL:
            capi.ev_loop_destroy(self._c_loop)

    def suspend(self):
        capi.ev_suspend(self._c_loop)

    def resume(self):
        capi.ev_suspend(self._c_loop)
