# Custom UUID attribute type for MySQL binary storage with base36 string representation
module ActiveRecord
  module Type
    class Uuid < Binary
      BASE36_LENGTH = 25 # 36^25 > 2^128

      class << self
        def generate
          uuid = SecureRandom.uuid_v7
          hex = uuid.delete("-")
          hex_to_base36(hex)
        end

        def hex_to_base36(hex)
          hex.to_i(16).to_s(36).rjust(BASE36_LENGTH, "0")
        end

        def base36_to_hex(base36)
          base36.to_s.to_i(36).to_s(16).rjust(32, "0")
        end
      end

      def serialize(value)
        return unless value

        binary = Uuid.base36_to_hex(value).scan(/../).map(&:hex).pack("C*")
        super(binary)
      end

      def deserialize(value)
        return unless value

        hex = value.to_s.unpack1("H*")
        Uuid.hex_to_base36(hex)
      end

      def cast(value)
        value
      end
    end
  end
end

# PostgreSQL UUID type: converts base36 strings ↔ standard UUID format for storage
# PostgreSQL's native uuid column type requires standard "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" format
class ActiveRecord::Type::PostgreSQLUuid < ActiveRecord::Type::Value
  def type
    :uuid
  end

  def cast(value)
    return unless value
    value.to_s
  end

  def serialize(value)
    return unless value
    hex = ActiveRecord::Type::Uuid.base36_to_hex(value.to_s)
    "#{hex[0..7]}-#{hex[8..11]}-#{hex[12..15]}-#{hex[16..19]}-#{hex[20..31]}"
  end

  def deserialize(value)
    return unless value
    hex = value.to_s.delete("-")
    ActiveRecord::Type::Uuid.hex_to_base36(hex)
  end
end

# Register the UUID type for Trilogy (MySQL), SQLite3, and PostgreSQL adapters
ActiveRecord::Type.register(:uuid, ActiveRecord::Type::Uuid, adapter: :trilogy)
ActiveRecord::Type.register(:uuid, ActiveRecord::Type::Uuid, adapter: :sqlite3)
