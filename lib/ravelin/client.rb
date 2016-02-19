module Ravelin
  class Client
    API_BASE = 'https://api.ravelin.com'

    def initialize(api_key:)
      @api_key = api_key

      @connection = Faraday.new(API_BASE, faraday_options) do |conn|
        conn.response :json, context_type: /\bjson$/
        conn.adapter Ravelin.faraday_adapter
      end
    end

    def send_event(**args)
      event = Event.new(**args)

      post("/v2/#{event.name}", event.serializable_hash)
    end

    private

    def post(url, payload)
      response = @connection.post(url, payload.to_json)

      if response.success?
        return Response.new(response)
      else
        handle_error_response(response)
      end
    end

    def handle_error_response(response)
      case response.status
      when 400, 403, 404, 405, 406
        raise InvalidRequestError.new(response)
      when 401
        raise AuthenticationError.new(response)
      when 429
        raise RateLimitError.new(response)
      else
        raise ApiError.new(response)
      end
    end

    def faraday_options
      {
        request: { timeout: Ravelin.faraday_timeout },
        headers: {
          'Authorization' => "token #{@api_key}",
          'Content-Type'  => 'application/json; charset=utf-8',
          'User-Agent'    => "Ravelin RubyGem/#{Ravelin::VERSION}"
        }
      }
    end
  end
end
