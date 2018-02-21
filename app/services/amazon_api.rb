class AmazonApi

  # require 'time'
  # require 'uri'
  # require 'openssl'
  # require 'base64'
  require 'net/http'

  # Your Access Key ID, as taken from the Your Account page
  ACCESS_KEY_ID = ENV['AMZN_AFFILIATE_ID']

  # Your Secret Key corresponding to the above ID, as taken from the Your Account page
  SECRET_KEY = ENV['AMZN_AFFILIATE_SECRET']

  # The region you are interested in
  ENDPOINT = "webservices.amazon.in"

  # Associate Tag
  ASSOCIATE_TAG = "frdbks123-21"

  REQUEST_URI = "/onca/xml"

  def self.itemsearch query
    params = {
      "Service" => "AWSECommerceService",
      "Operation" => "ItemSearch",
      "AWSAccessKeyId" => ACCESS_KEY_ID,
      "AssociateTag" => ASSOCIATE_TAG,
      "SearchIndex" => "Books",
      "ResponseGroup" => "EditorialReview,Images,ItemAttributes,OfferFull",
      "Keywords" => query,
      "Timestamp" => Time.now.gmtime.iso8601
    }

    # Generate the canonical query
    canonical_query_string = params.sort.collect do |key, value|
      [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
    end.join('&')

    # Generate the string to be signed
    string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"

    # Generate the signature required by the Product Advertising API
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SECRET_KEY, string_to_sign)).strip()

    # Generate the signed URL
    request_url = "http://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

    puts "Signed URL: \"#{request_url}\""

    response = Net::HTTP.get URI(request_url)

    response = Nokogiri::XML response

    response = Hash.from_xml response.to_s

    File.write("#{Rails.root}/test.json", JSON.pretty_generate(response))
  end

end
