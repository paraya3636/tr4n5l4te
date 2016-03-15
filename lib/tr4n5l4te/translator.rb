require 'open-uri'

module Tr4n5l4te
  class Translator
    START_PAGE = 'https://translate.google.com/'.freeze

    attr_reader :sleep_time, :agent

    def initialize(args = {})
      @sleep_time = args.fetch(:sleep_time, 2)
      @agent = Agent.new
      load_cookies
      agent.visit(START_PAGE)
      sleep_default
      store_cookies
    end

    def translate(text, from_lang, to_lang)
      encoded_text = URI.encode(text)
      url = "https://translate.google.com/##{from_lang}/#{to_lang}/#{encoded_text}"
      agent.visit(url)
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
