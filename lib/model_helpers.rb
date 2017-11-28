module ModelHelpers
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def random(cnt)
      offset(rand(count - cnt))[0..(cnt-1)]
    end

    def build_query_args(attributes, matching_this)
      args = []

      query_str = attributes.map do |attr|
        args << matching_this
        "lower(#{attr}) like ?"
      end.join(" or ")

      [query_str] + args
    end
  end

  module CredentialsHelper
    def creds
      JSON(AdtekioUtilities::Encrypt.
           decode_from_base64(credentials ||
                      AdtekioUtilities::Encrypt.encode_to_base64({}.to_json)))
    end

    def creds=(hsh)
      update(:credentials =>
             AdtekioUtilities::Encrypt.encode_to_base64(hsh.to_json))
    end
  end

  def update_from_url(agent)
    page      = agent.get(url)
    more_data = {}

    page.search("div.webprofiles").search("li").each do |elem|
      key            = elem.search("p").attribute("id").value
      value          = elem.search("a").attribute("href").value.strip
      more_data[key] = value
    end

    page.search("div.contact-data").search("li").each do |elem|
      key            = elem.search("p").first.text
      value          = elem.search("p").last.text
      more_data[key] = value
    end

    yield(page, more_data) if block_given?

    update(:data => (data || {}).merge(more_data))
  end
end
