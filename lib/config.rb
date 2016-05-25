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
      File.join(File.dirname(File.expand_path(__FILE__)), default_library_name)
    end

    def default_library_name
      case Utils.os 
      when :macosx       then "libui.dylib"
      when :windows      then "libui.dll" # TODO Verify ...
      when :linux, :unix then "libui.so"
      end
    end
  end
end
