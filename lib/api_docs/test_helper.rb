# frozen_string_literal: true

module ApiDocs
  module TestHelper
    module InstanceMethods
      # Method that allows test creation and will document results in a YAML
      # file.
      #
      # Example usage:
      #   api_call(:get, '/users/:id', :id => 12345) do |doc|
      #     doc.description = 'Something for the docs'
      #     ... regular test code
      #   end
      def api_call(method, path, params = {}, headers = {})
        parsed_path   = path.dup
        parsed_params = params.dup

        parsed_params.each do |k, v|
          parsed_params.delete(k) if parsed_path.gsub!(":#{k}", v.to_s)
        end

        # Making actual test request. Based on the example above:
        #   get '/users/12345'

        send(method, parsed_path, params: parsed_params, headers: headers)

        meta = {}
        yield meta if block_given?

        # Not writing anything to the files unless there was a demand
        if ApiDocs.config.generate_on_demand
          return unless ENV['API_DOCS']
        end

        # Assertions inside test block didn't fail. Preparing file
        # content to be written
        c = request.filtered_parameters['controller']
        a = request.filtered_parameters['action']

        file_path  = File.expand_path("#{c.tr('/', ':')}.yml",
                                      ApiDocs.config.docs_path)
        key_params = ApiDocs::TestHelper.api_deep_clean_params(params, true)
        params     = ApiDocs::TestHelper.api_deep_clean_params(params)

        # Marking response as an unique
        key = 'ID-' + Digest::MD5.hexdigest("
                                            #{method}#{path}#{meta}#{key_params}#{response.status}}
      ")

        data = if File.exist?(file_path)
                 begin
                   YAML.load_file(file_path)
                 rescue
                   {}
                 end
               else
                 {}
               end

        data[a] ||= {}
        data[a][key] = {
          'meta'        => meta,
          'method'      => request.method,
          'path'        => path,
          'headers'     => headers,
          'params'      => ApiDocs::TestHelper.api_deep_clean_params(params),
          'status'      => response.status,
          'body'        => response.body
        }
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'w') { |f| f.write(data.to_yaml) }
      end
    end

    # Cleans up params. Removes things like File object handlers
    # Sets up ignored values so we don't generate new keys for same data
    def self.api_deep_clean_params(params, for_key = false)
      case params
      when Hash
        if for_key
          params = params.with_indifferent_access
          ApiDocs.config.exclude_key_params.to_a.each { |e| params.delete(e) }
        end

        params.each_with_object({}) do |(key, value), res|
          res[key.to_s] = ApiDocs::TestHelper.api_deep_clean_params(value, for_key)
        end
      when Array
        params.collect { |value| ApiDocs::TestHelper.api_deep_clean_params(value) }
      else
        case params
        when Rack::Test::UploadedFile
          'BINARY'
        else
          params.to_s
        end
      end
    end
  end
end

ActionDispatch::IntegrationTest.send :include, ApiDocs::TestHelper::InstanceMethods
