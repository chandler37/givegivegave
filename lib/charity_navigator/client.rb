# See https://charitynavigator.github.io/api/CharityNavigatorAPI/generated/RZenHtmlDocs/CharityNavigator_doc.html

module CharityNavigator
  class Client
    BASE_URL = "https://api.data.charitynavigator.org".freeze

    class Error < StandardError
    end

    class NotFoundError < Error
    end

    def self.call(path, params: {}, without_reading_from_cache: false, method:)
      unless path[0] == "/"
        raise "path must start with /"
      end

      cacheline = nil
      if method == :get
        cacheline = Cacheline.lookup_cacheline("#{BASE_URL}/v2#{path}", params)
      end
      if cacheline
        Rails.logger.info "Cacheline saving us a CharityNavigator API hit"
        return ::JSON.parse(cacheline.uncompressed_body)
      end

      Rails.logger.info "Hitting CharityNavigator API"

      unless ENV["CHARITYNAVIGATOR_APP_ID"].present? && ENV["CHARITYNAVIGATOR_APP_KEY"].present?
        raise "bad env"
      end

      conn = ::Faraday.new(url: BASE_URL) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger do |logger|
          logger.filter(/(app_key=)(\w+)/, '\1[REMOVED]')
          logger.filter(/(app_id=)(\w+)/, '\1[REMOVED]')
        end
        faraday.adapter ::Faraday.default_adapter
      end

      response = conn.public_send(
        method,
        "/v2#{path}",
        {
          app_id: ENV["CHARITYNAVIGATOR_APP_ID"],
          app_key: ENV["CHARITYNAVIGATOR_APP_KEY"],
        }.merge(params)
      )

      unless response.status == 200
        if response.status == 404
          raise NotFoundError
        end
        raise Error.new("response.status=#{response.status} and body=#{response.body} for path #{path}")
      end

      unless ENV["WITHOUT_UPDATING_CACHE"] == "true"
        Cacheline.populate_cache!("#{BASE_URL}/v2#{path}", params, response.body)
        # TODO(chandler37): write a rake task that cleans out the least
        # recently used items
      end

      ::JSON.parse(response.body)
    end

    def self.get(path, params: {}, without_reading_from_cache: false)
      call(path, params: params, method: :get)
    end

  end
end
