# See https://charitynavigator.github.io/api/CharityNavigatorAPI/generated/RZenHtmlDocs/CharityNavigator_doc.html

module CharityNavigator
  class Client
    def self.call(path, params: {}, method:)
      unless path[0] == "/"
        raise "path must start with /"
      end
      unless ENV["CHARITYNAVIGATOR_APP_ID"].present? && ENV["CHARITYNAVIGATOR_APP_KEY"].present?
        raise "bad env"
      end
      conn = ::Faraday.new(url: "https://api.data.charitynavigator.org") do |faraday|
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
        raise "response.status=#{response.status} and body=#{response.body} for path #{path}"
      end
      ::JSON.parse(response.body)
    end

    def self.get(path, params: {})
      call(path, params: params, method: :get)
    end

  end
end
