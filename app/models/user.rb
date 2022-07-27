# frozen_string_literal: true

class User
  include ActiveModel::Serializers::JSON

  attr_accessor :id, :enabled, :display_name, :email, :picture, :identities, :metadata, :attributes

  def initialize(hash)
    hash.each { |key, value| public_send("#{key}=", value) }
  end

  def as_json(_options = {})
    {
      id: @id,
      enabled: @enabled,
      display_name: @display_name,
      email: @email,
      picture: @picture,
      identities: @identities,
      metadata: @metadata,
      attributes: @attributes
    }
  end

  class << self
    def find(id)
      response = HTTP
                 .headers(
                   {
                     Authorization: "basic #{ENV.fetch('ASERTO_AUTHORIZER_API_KEY', nil)}",
                     "aserto-tenant-id": ENV.fetch("ASERTO_TENANT_ID", nil),
                     "Content-Type": "application/json"
                   }
                 )
                 .get(
                   "#{ENV.fetch('ASERTO_AUTHORIZER_SERVICE_URL',
                                nil)}/api/v1/dir/users/#{id}?fields.mask=id,display_name,picture,email"
                 )

      if response.status != 200
        Rails.logger.debug response.inspect
        raise StandardError, "could not fetch user"
      end

      user_data = response.parse["result"]
      User.new(user_data)
    end
  end
end
