module SwaggerJekyll
  class Verb
    attr_accessor :verb, :path, :responses
    def initialize(verb, path, hash, specification)
      @verb = verb
      @path = path
      @hash = hash
      @specification = specification
    end

    def to_liquid
      @hash.dup.merge(
        'verb' => @verb,
        'path' => @path,
        'responses' => responses,
        'sample_response' => sample_response)
    end

    def sample_response?
      @hash.dig('responses', '200', 'examples', 'application/json')
    end

    def sample_response
      if @_sample_response.nil?
        example_json = @hash.dig('responses', '200', 'examples', 'application/json')
        if example_json
          @_sample_response = JSON.pretty_generate(example_json)
        end
      end

      @_sample_response
    end

    def responses
      responses_hash.values
    end

    # FIXME: Move to module mixin
    def method_missing(method_sym, *arguments, &block)
      if @hash.key?(method_sym.to_s)
        @hash[method_sym.to_s]
      else
        super
      end
    end

    private

    def responses_hash
      if @_responses_hash.nil?
        @_responses_hash = {}
        @hash['responses'].each do |code, response_hash|
          @_responses_hash[code] = Response.new(code, response_hash, @specification)
        end
      end

      @_responses_hash
    end
  end
end
