# frozen_string_literal: true

require 'api_docs/version'
require 'api_docs/configuration'
require 'api_docs/test_helper'
require 'api_docs/web'

module ApiDocs
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration
  end
end
