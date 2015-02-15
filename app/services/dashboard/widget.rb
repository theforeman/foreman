module Dashboard
  class Widget
    attr_reader :id, :name, :col, :row, :sizex, :sizey, :hide

    def initialize(id, options)
      @id = id
      @name = options[:name] || id
      @col = options[:col] || 1
      @row = options[:row] || 1
      @sizex = options[:sizex] || 4
      @sizey = options[:sizey] || 1
      @hide = options[:hide] || false
    end
  end
end
