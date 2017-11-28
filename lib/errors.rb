module ErrorPage
  class FormatNotSupported < StandardError
    def http_status
      406
    end
  end
end
