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
      return '' if text.nil? || text == ''
      text.strip!
      return '' if text == ''
      encoded_text = URI.encode(text)
      url = "#{START_PAGE}/##{from_lang}/#{to_lang}/#{encoded_text}"
      load_cookies
      agent.visit(url)
      store_cookies
      sleep_default
      result_box = browser.find('#result_box')
      result_box.text
    end

    private

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
