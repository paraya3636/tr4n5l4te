require 'open-uri'

module Tr4n5l4te
  class Translator
    START_PAGE = 'https://translate.google.com'.freeze

    attr_reader :sleep_time, :agent

    def initialize(args = {})
      @sleep_time = args.fetch(:sleep_time, 2)
      @agent = Agent.new
    end

    def translate(text, from_lang, to_lang)
      puts "Translating: #{text}"
      encoded_text = validate_and_encode(text)
      return "" if encoded_text == ""
      smart_visit(translator_url(encoded_text, from_lang, to_lang))
      result_box = browser.find('.tlid-translation')
      result_box.text
    end

    private

    def validate_and_encode(text)
      return "" if text.nil?
      fail "Cannot translate a [#{text.class}]: '#{text}'" unless text.respond_to?(:gsub)
      text.strip!
      URI.encode(text)
    end

    def smart_visit(url)
      load_cookies
      agent.visit(url)
      store_cookies
      sleep_default
    end

    def translator_url(encoded_text, from_lang, to_lang)
      "#{START_PAGE}/##{from_lang}/#{to_lang}/#{encoded_text}"
    end

    def store_cookies
      agent.store_cookies(Tr4n5l4te.cookie_file)
    end

    def load_cookies
      agent.load_cookies(Tr4n5l4te.cookie_file)
    end

    def sleep_default
      sleep(sleep_time)
    end

    def browser
      agent.browser
    end
  end
end
