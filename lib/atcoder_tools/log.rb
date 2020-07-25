require 'logger'
module Log
  LoggerIns = Logger.new(STDOUT)
  if ENV['ATCODER_TOOLS_ENV'] == 'development'
    LoggerIns.level = Logger::DEBUG
  else
    LoggerIns.level = Logger::INFO
  end
  
  def log_debug(msg)
    LoggerIns.debug(msg)
  end
 
  def log_info(msg)
    LoggerIns.info(msg)
  end

  def log_warn(msg)
    LoggerIns.warn(msg)
  end

  def log_error(msg)
    LoggerIns.error(msg)
  end
end