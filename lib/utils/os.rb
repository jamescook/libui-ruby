require 'rbconfig'

module LibUI
  class Utils
    class UnknownOperatingSystem < StandardError; end

    # Selenium way of OS detection
    def self.os
      host_os = RbConfig::CONFIG["host_os"]
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise UnknownOperatingSystem, "unknown OS: #{host_os.inspect}"
      end
    end
  end
end
