class Cacheline < ApplicationRecord
  before_validation :strip_authentication
  before_save :compress_body
  after_find :uncompress_body
  attr_accessor :uncompressed_body

  APP_KEY_PLACEHOLDER = "<APP_KEY>".freeze
  APP_ID_PLACEHOLDER = "<APP_ID>".freeze

  # this cache will need an update to strip authentication from any other APIs
  # we use:
  VALID_URL_REGEX = /\Ahttps:..api.data.charitynavigator.org.v2.*\bapp_id=#{APP_ID_PLACEHOLDER}.*&app_key=#{APP_KEY_PLACEHOLDER}/i
  validates :url_minus_auth, presence: true, format: {
              with: VALID_URL_REGEX
            }

  # If we get a 5xx we should retry, not cache the error. We shouldn't get a
  # 3xx. 4xx is a bug we muast fix.
  validates :http_status, presence: true, numericality: {
              only_integer: true, equal_to: 200
            }

  validates :uncompressed_body, presence: true

  private

  def compress_body
    if @uncompressed_body.blank?
      raise "needs a body"
    end
    self.body = compress(@uncompressed_body)
  end

  def uncompress_body
    if body.blank?
      raise "needs a body"
    end
    @uncompressed_body = uncompress(body)
  end

  def compress(x)
    Base64.strict_encode64(Zlib::Deflate.deflate(x, Zlib::BEST_SPEED))
  end

  def uncompress(x)
    Zlib::Inflate.inflate(Base64.decode64(x))
  end

  STRIPPED_URL_REGEX = /\Ahttps:..api.data.charitynavigator.org.v2.*\bapp_id=#{APP_ID_PLACEHOLDER}.*&app_key=#{APP_KEY_PLACEHOLDER}/i

  def strip_authentication
    return if url_minus_auth =~ STRIPPED_URL_REGEX
    if url_minus_auth.include?(APP_KEY_PLACEHOLDER) || url_minus_auth.include?(APP_ID_PLACEHOLDER)
      raise "Give URLs with auth"
    end
    self.url_minus_auth = url_minus_auth.gsub(
      /([?&]app_key=)(\w+)/, "\\1#{APP_KEY_PLACEHOLDER}"
    )
    self.url_minus_auth = url_minus_auth.gsub(
      /([?&]app_id=)(\w+)/, "\\1#{APP_ID_PLACEHOLDER}"
    )
  end
end
