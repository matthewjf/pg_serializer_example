module PgSerializable
  class Aliaser
    def self.next!(curr=nil)
      curr ? "z#{curr[1].to_i + 1}" : 'z0'
    end
  end
end
