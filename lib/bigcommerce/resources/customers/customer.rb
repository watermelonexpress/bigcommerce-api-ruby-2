# frozen_string_literal: true

require 'jwt'
require 'securerandom'

# Customer
# Identity and account details for customers shopping at a Bigcommerce store.
# https://developer.bigcommerce.com/api/stores/v2/customers

module Bigcommerce
  class Customer < Resource
    include Bigcommerce::ResourceActions.new uri: 'customers/%d'

    PERMITTED_OPTIONAL_CLAIMS = %w[channel_id request_ip].freeze

    property :id
    property :_authentication
    property :count
    property :company
    property :first_name
    property :last_name
    property :email
    property :phone
    property :date_created
    property :date_modified
    property :store_credit
    property :registration_ip_address
    property :customer_group_id
    property :notes
    property :addresses
    property :tax_exempt_category
    property :accepts_marketing
    property :form_fields

    def self.count(params = {})
      get 'customers/count', params
    end

    # Generate a token that can be used to log the customer into the storefront.
    # This requires your app to have the store_v2_customers_login scope and to
    # be installed in the store.
    def login_token(config: Bigcommerce.config, redirect_to: '/', optional_claims: {})
      payload = {
        'iss' => config.client_id,
        'iat' => Time.now.to_i,
        'jti' => SecureRandom.uuid,
        'operation' => 'customer_login',
        'store_hash' => config.store_hash,
        'customer_id' => id,
        'redirect_to' => redirect_to
      }

      optional_claims = optional_claims.slice(*PERMITTED_OPTIONAL_CLAIMS)
      payload.merge!(optional_claims) if optional_claims.any?

      JWT.encode(payload, config.client_secret, 'HS256', { typ: 'JWT' })
    end
  end
end
