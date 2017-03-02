module Sipity
  module Conversions
    # Responsible for converting a request and pager into a URL
    # @see http://jsonapi.org/format/#fetching-pagination
    module ConvertToJsonApiLink
      # @api public
      #
      # Responsible for converting the given pagination_method, request, and pager into a URL (String) that conforms
      # to the JSON-API pagination specification
      #
      # @param pagination_method [Symbol]
      # @param request [ActionDispatch::Request]
      # @param pager [#last_page?, #first_page?, #total_pages, #prev_page, #next_page]
      # @return String
      #
      # @see http://jsonapi.org/format/#fetching-pagination
      def self.call(pagination_method, request:, pager:)
        case pagination_method
        when :self then url_for(request: request, query_parameters: request.query_parameters)
        when :next
          return nil if pager.last_page?
          url_for(request: request, query_parameters: request.query_parameters.merge(page: pager.next_page))
        when :prev
          return nil if pager.first_page?
          url_for(request: request, query_parameters: request.query_parameters.merge(page: pager.prev_page))
        when :last
          url_for(request: request, query_parameters: request.query_parameters.merge(page: pager.total_pages))
        when :first then
          url_for(request: request, query_parameters: request.query_parameters.merge(page: 1))
        end
      end

      def self.url_for(request:, query_parameters:)
        path_without_params = "#{request.scheme}://#{request.host_with_port}#{request.path}"
        return path_without_params if query_parameters.empty?
        "#{path_without_params}?#{query_parameters.to_query}"
      end
      private_class_method :url_for
    end
  end
end
