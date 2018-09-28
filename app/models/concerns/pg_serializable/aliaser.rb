module PgSerializable
  class Aliaser
    def initialize(index=0)
      @index = index
    end

    def next
      self.class.new(@index+1)
    end

    def name
      "z#{@index}"
    end
  end
end
