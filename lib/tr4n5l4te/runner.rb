require 'optimist'
require 'colored'
require 'fileutils'
require 'midwire_common/string'

module Tr4n5l4te
  class Runner
    attr_accessor :logger, :options, :count

    def self.instance
      @instance ||= new
    end

    def initialize
      @options = collect_args
      validate_args
    end

    def run
      start_time = Time.now
      log_identifier(start_time)
      @count = 0

      # configure
      Tr4n5l4te.configure do |config|
        config.timeout = options[:timeout]
      end

      # TODO: ここでディレクトリ指定できれば全自動でも行けるかも
      Dir.glob("*.yml", base:options[:directory]) do |item|
        filepath = "#{options[:directory]}/#{item}"
        hash = YAML.load_file(filepath)
        translated = process(hash)
        store_translation(translated, filepath)

        puts("Processed #{@count} strings in [#{Time.now - start_time}] seconds.".yellow)
      end
    end

    private

    def process(hash)
      hash.each_with_object({}) do |pair, h|
        key, value = pair
        h[key] = value.is_a?(Hash) ? process(value) : translate(value)
        h
      end
    end

    def translate(string)
      @count += 1
      puts("[#{string}]") if options[:verbose]
      translator.translate(string, from_lang, options[:lang])
    end

    def translator
      @translator ||= Translator.new(sleep_time: options[:sleep_time])
    end

    def from_lang
      # TODO: とりあえずen固定
      "en"
    end

    def store_translation(translated, filePath)
      data = translated.to_yaml(line_width: -1)
      # dir = File.dirname(options[:yaml_file])
      # base = File.basename(options[:yaml_file]).gsub(/#{from_lang}\.yml$/, '')
      # 同一ファイル名で上書き
      File.open(filePath, 'w') { |f| f.write(data) }
    end

    # rubocop:disable Metrics/MethodLength
    def collect_args
      Optimist.options do
        opt(
            :directory,
            "A YAML locale file - filename determines source language 'en.yml' - English",
            type: :string, required: false, short: 'd')
        opt(
          :yaml_file,
          "A YAML locale file - filename determines source language 'en.yml' - English",
          type: :string, required: false, short: 'y')
        opt(
          :lang,
          'Destination language',
          type: :string, required: false, short: 'l')
        opt(
          :list,
          'List known languages',
          type: :boolean, required: false)
        opt(
          :sleep_time,
          'Sleep time',
          type: :integer, default: 2, short: 's')
        opt(
          :timeout,
          'Poltergeist timeout option - default 30',
          type: :integer, default: 30, short: 't')
        opt(
          :verbose,
          'Be verbose with output',
          type: :boolean, required: false, short: 'v', default: false)
      end
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def validate_args
      if options[:list]
        puts('Valid languages:'.yellow + "\n\n")
        puts(Language.list.join(', ').yellow + "\n\n")
        exit
      end
      if !options[:lang_given] || !Language.valid?(options[:lang])
        puts('Valid languages:'.red + "\n\n")
        puts(Language.list.join(', ').yellow + "\n\n")
        Optimist.die(:lang, "'#{options[:lang]}' language unknown".red)
      end
=begin
      if !options[:yaml_file_given] || !File.exist?(options[:yaml_file])
        puts('A YAML file is required:'.red + "\n\n")
        Optimist.die(:yaml_file, "'#{options[:yaml_file]}' not found".red)
      end
      options[:lang] = Language.ensure_code(options[:lang])
=end
    end
    # rubocop:enable Metrics/AbcSize

    def log_identifier(start_time)
      timestr = start_time.strftime('%H:%M:%S.%3N')
      puts("Starting Tr4n5l4te v#{Tr4n5l4te::VERSION} @#{timestr}".green)
    end
  end
end
