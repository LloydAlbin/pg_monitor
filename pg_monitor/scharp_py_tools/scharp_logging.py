import logging

class Logger():
    __author__ = "Lloyd Albin (lalbin@fredhutch.org, lloyd@thealbins.com)"
    __version__ = "0.0.34"
    __copyright__ = "Copyright (C) 2019 Fred Hutchinson Cancer Research Center"

    from logging import DEBUG, ERROR, CRITICAL, WARNING, INFO
    slogger = logging.getLogger(__name__)

    def __init__(self, level = logging.DEBUG, format = "", threading = False, file_name = None):
        self.slogger.setLevel(level)
        set_level = level
        if format:
            #print ("CUSTOM FORMAT")
            formatter = logging.Formatter(format)
            set_format = format
        else:
            if threading:
                #print ("THREADING ON")
                formatter = logging.Formatter('%(asctime)s [%(levelname)s] (%(threadName)-10s) %(message)s')
                set_format = '%(asctime)s [%(levelname)s] (%(threadName)-10s) %(message)s'
            else:
                #print ("THREADING OFF")
                formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s')
                set_format = '%(asctime)s [%(levelname)s] %(message)s'
        if (file_name):
            logging.basicConfig(format=set_format, level=set_level, filename=file_name)
        else:
            logging.basicConfig(format=set_format, level=set_level)
        self.addLoggingLevel("TRACE", int(5))
        
    def critical(self, message, *args, **kwargs):
        self.slogger.critical(message, *args, **kwargs)

    def error(self, message, *args, **kwargs):
        self.slogger.error(message, *args, **kwargs)

    def warning(self, message, *args, **kwargs):
        self.slogger.warning(message, *args, **kwargs)
    
    def info(self, message, *args, **kwargs):
        self.slogger.info(message, *args, **kwargs)
    
    def debug(self, message, *args, **kwargs):
        self.slogger.debug(message, *args, **kwargs)
        
    def log(self, levelNum, message, *args, **kwargs):
        self.slogger.log(levelNum, message, *args, **kwargs)
        

    def addLoggingLevel(self, levelName, levelNum, methodName=None):
        """
        Comprehensively adds a new logging level to the `logging` module and the
        currently configured logging class.
    
        `levelName` becomes an attribute of the `logging` module with the value
        `levelNum`. `methodName` becomes a convenience method for both `logging`
        itself and the class returned by `logging.getsloggerClass()` (usually just
        `logging.slogger`). If `methodName` is not specified, `levelName.lower()` is
        used.
    
        To avoid accidental clobberings of existing attributes, this method will
        raise an `AttributeError` if the level name is already an attribute of the
        `logging` module or if the method name is already present 
    
        Example
        -------
        >>> addLoggingLevel('TRACE', logging.DEBUG - 5)
        >>> logging.getslogger(__name__).setLevel("TRACE")
        >>> logging.getslogger(__name__).trace('that worked')
        >>> logging.trace('so did this')
        >>> logging.TRACE
        5
    
        https://stackoverflow.com/questions/2183233/how-to-add-a-custom-loglevel-to-pythons-logging-facility
        
        Modified by Lloyd to work as part of a class instead of directly inside the Python script
        """
        if not methodName:
            methodName = levelName.lower()
    
        # This method was inspired by the answers to Stack Overflow post
        # http://stackoverflow.com/q/2183233/2988730, especially
        # http://stackoverflow.com/a/13638084/2988730
        def logForLevel(self, message, *args, **kwargs):
            if self.isEnabledFor(levelNum):
                self._log(levelNum, message, args, **kwargs)
        def logToRoot(message, *args, **kwargs):
            logging.log(levelNum, message, *args, **kwargs)
    
        if not hasattr(logging, levelName):
            logging.addLevelName(levelNum, levelName)
            setattr(logging, levelName, levelNum)
        if not hasattr(self, levelName):
            setattr(self, levelName, levelNum)
        if not hasattr(logging, methodName):
            setattr(logging, methodName, logToRoot)
        if not hasattr(self, methodName):
            setattr(self, methodName, logToRoot)
        if not hasattr(logging.getLoggerClass(), methodName):
            setattr(logging.getLoggerClass(), methodName, logForLevel)

    def close(self):
        close_logger = logging.getLogger()
        for handler in close_logger.handlers:
            close_logger.removeHandler(handler)
