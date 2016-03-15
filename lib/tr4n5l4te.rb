require 'tr4n5l4te/version'

require 'midwire_common/string'
require 'midwire_common/yaml_setting'
require 'midwire_common/hash'

module Tr4n5l4te
  class << self
    def root
      Pathname.new(File.dirname(__FILE__)).parent
    end

    def string_id
      to_s.snakerize
    end

    def default_config_directory
      ".#{string_id}"
    end

    def default_cookie_filename
      'cookies.yml'
    end

    def home_directory
      ENV.fetch('HOME')
    end

    # If you don't have a HOME directory defined, you are on an OS that is
    # retarded, and this call will fail.
    def cookie_file
      dir = File.join(home_directory, default_config_directory)
      module_string = string_id.upcase
      file = ENV.fetch(
        "#{module_string}_COOKIES",
        File.join(dir, default_cookie_filename)
      )
      FileUtils.mkdir_p(dir)
      FileUtils.touch(file)
      file
    end
  end

  autoload :Agent,      'tr4n5l4te/agent'
  autoload :Translator, 'tr4n5l4te/translator'
end
