require 'mechanize'

module BlzSearch
  extend self

  def find_bank_name(iban)
    FigoSupportedBank.get_bank(iban).try(:bank_name) ||
      scrape_bank_name(iban) || "Unknown Bank"
  end

  def scrape_bank_name(iban)
    return nil unless IBANTools::IBAN.valid?(iban.code)
    return nil if iban.country_code != 'DE'

    page = mechanize_agent.get(BlzSearchUrls[iban.country_code])

    form = page.forms.select do |a|
      a.name == 'blzSucheForm' &&
        a.fields.map { |b| b.name }.include?('bankRoutingNumber')
    end.first

    form.fields.select do |a|
      a.name == 'bankRoutingNumber'
    end.first.value = iban.to_local[:blz]

    elem = form.submit.search("tr td[class='center']").
      select { |a| a.children.text == "\nJa\n"}.first

    elem && elem.parent.search("a").children.text.strip
  end

  private

  def mechanize_agent(user_agent = :use_mozilla)
    Mechanize.new.tap do |agent|
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      if user_agent == :use_mozilla
        agent.user_agent_alias = 'Linux Mozilla'
      else
        agent.user_agent = user_agent
      end
    end
  end
end
