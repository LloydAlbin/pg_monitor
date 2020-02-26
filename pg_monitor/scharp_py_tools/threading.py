import threading

class Threader():
    __author__ = "Lloyd Albin (lalbin@fredhutch.org, lloyd@thealbins.com)"
    __version__ = "0.0.23"
    __copyright__ = "Copyright (C) 2019 Fred Hutchinson Cancer Research Center"
    
    from scharp_py_tools import scharp_logging
    logger = scharp_logging.Logger()

    MAX_THREADS = int('0')
    main_thread = threading.main_thread()
    
    def spawn_thread(self, methodName, *args, **kwargs):
        self.logger.debug('Testing Process')
        if (self.MAX_THREADS == int('0')):
            methodName(*args, **kwargs)
        else:
            reuse_thread = False
            self.logger.debug('Active Threads: %s', threading.active_count())
            while not reuse_thread:
                if (threading.active_count() <= self.MAX_THREADS):
                    self.logger.debug('start new worker thread')
                    t = threading.Thread(target=methodName, args=args, kwargs=kwargs)
                    t.start()
                    reuse_thread = True

    def wait_for_all_threads(self):
        for t in threading.enumerate():
            if t is self.main_thread:
                continue
            self.logger.debug('joining %s', t.getName())
            self.logger.debug('Active Threads: %s', threading.active_count())
            t.join()
