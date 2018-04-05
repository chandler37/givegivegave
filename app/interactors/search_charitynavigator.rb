class SearchCharitynavigator
  include Interactor

  delegate :search, :ein, to: :context

  def call
    context.ein = context.ein.try(:gsub, "-", "")
    unless search.present? || ein.present?
      byebug
      raise ArgumentError.new("no search query")
    end
    if search.present? && ein.present?
      raise ArgumentError.new("pick one or the other")
    end
    begin
      if search.present?
        context.response_json = CharityNavigator::Client.get(
          "/Organizations", params: {search: search}
        )
      else
        r = CharityNavigator::Client.get(
          "/Organizations/#{ein}"
        )
        unless r.is_a?(Hash) && r["ein"] == ein
          context.fail!(error: "API returned unexpected schema")
        end
        context.response_json = [r]
      end
    rescue => exc
      context.fail!(error: "API call failed: #{exc.message}")
    end
  end
end
