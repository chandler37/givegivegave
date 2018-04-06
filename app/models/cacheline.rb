class Cacheline < ApplicationRecord
  before_validation :strip_authentication
  before_save :compress_body
  after_find :uncompress_body
  attr_accessor :uncompressed_body

  # this cache will need an update to strip authentication from any other APIs
  # we use:
  VALID_URL_REGEX = /\Ahttps:\/\/api.data.charitynavigator\.org\/v2/
  validates :url_minus_auth, presence: true, format: {
              with: VALID_URL_REGEX,
              message: "is for an unknown API for which we may need to strip credentials"
            }

  # If we get a 5xx we should retry, not cache the error. We shouldn't get a
  # 3xx. 4xx is a bug we muast fix.
  validates :http_status, presence: true, numericality: {
              only_integer: true, equal_to: 200
            }

  validates :uncompressed_body, presence: true

  def self.lookup_cacheline(url, params_without_auth)
    if params_without_auth["app_key"]
      raise "oh noes!"
    end
    uri = URI(url)
    uri.query = URI.encode_www_form(params_without_auth.map { |k, v| [k.to_s, v] }.sort)
    find_by(url_minus_auth: uri.to_s)
  end

  def self.populate_cache!(url, params_without_auth, uncompressed_body)
    if params_without_auth["app_key"]
      raise "oh noes!"
    end
    uri = URI(url)
    uri.query = URI.encode_www_form(params_without_auth.map { |k, v| [k.to_s, v] }.sort)
    line = find_or_initialize_by(url_minus_auth: uri.to_s)
    line.uncompressed_body = uncompressed_body
    line.http_status = 200
    line.save!
  end

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

  def strip_authentication # must be idempotent in case someone tries to save, fails, and saves again
    uri = URI(url_minus_auth)
    if uri.nil? || uri.query.nil?
      errors.add(:url_minus_auth, "is not a valid URI")
      return
    end
    ary = URI.decode_www_form(uri.query).sort.select do |k, v|
      !["app_id", "app_key"].include?(k)
    end
    uri.query = URI.encode_www_form(ary)
    self.url_minus_auth = uri.to_s
    if url_minus_auth.include?("app_key=")
      raise "oh noes!"
    end
  end
end
