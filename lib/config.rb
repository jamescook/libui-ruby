require "singleton"

module LibUI
  class Config
    include Singleton

    # Path to libui.so/libui.dylib
    attr_writer :library_path

    def library_path
      @library_path || default_local_library_path
    end

    private

    def default_local_library_path
      ext = RbConfig::CONFIG['DLEXT']
      dir = RbConfig::CONFIG['libdir']
      File.join(dir, "libui.#{ext}")
    end
  end
end
