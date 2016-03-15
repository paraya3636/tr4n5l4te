require 'open-uri'

module Tr4n5l4te
  class Translator
    START_PAGE = 'https://translate.google.com/'
    COOKIE_FILE = ""
    DEFAULT_MIN_SLEEP = 3

    def initialize(args = {})
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

    def browser
      agent.browser
    end

    def store_cookies
      agent.store_cookies(Tr4n5l4te.cookie_file)
    end

    def load_cookies
      agent.load_cookies(Tr4n5l4te.cookie_file)
    end

    def sleep_default
      sleep(DEFAULT_MIN_SLEEP)
    end

    def browser
      agent.browser
    end

    def agent
      @agent
    end
  end
end
