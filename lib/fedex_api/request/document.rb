require 'fedex_api/request/shipment'
require 'fedex_api/document'

module FedexApi
  module Request
    class Document < Shipment

      def initialize(credentials, options={})
        super(credentials, options)

        @shipping_document = options[:shipping_document]
        @filenames = options.fetch(:filenames) { {} }
      end

      def add_custom_components(xml)
        super

        add_shipping_document(xml) if @shipping_document
      end

      private

      # Add shipping document specification
      def add_shipping_document(xml)
        xml.ShippingDocumentSpecification{
          Array(@shipping_document[:shipping_document_types]).each do |type|
            xml.ShippingDocumentTypes type
          end
          hash_to_xml(xml, @shipping_document.reject{ |k| k == :shipping_document_types})
        }
      end

      def success_response(api_response, response)
        super

        shipment_documents = response.merge!({
          :filenames => @filenames
        })

        FedexApi::Document.new shipment_documents
      end

    end
  end
end
