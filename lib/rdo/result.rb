module RDO
  class Result
    include Enumerable

    def each(&block)
      self
    end
  end
end
