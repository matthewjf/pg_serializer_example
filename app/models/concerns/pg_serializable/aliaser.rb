module PgSerializable
  class Aliaser
    def self.next!(curr=nil)
      curr ? "z#{curr[1].to_i + 1}" : 'z0'
    end

    def initialize(curr_index=0)
      @index = curr_index
    end

    def next!
      @index += 1
      self
    end

    def to_s
      "z#{@index}"
    end
  end
end
