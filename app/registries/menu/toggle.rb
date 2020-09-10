module Menu
  class Toggle < Node
    attr_accessor :icon
    def initialize(name, caption, icon)
      @caption = caption
      @icon = icon || ""
      super name.to_sym
    end

    def to_hash
      {type: :sub_menu, name: @caption, icon: @icon, children: children_hash}
    end

    def children_hash
      list = authorized_children
      list.reject! do |child|
        index = list.index(child)
        child.is_a?(Menu::Divider) && (index == list.size - 1 || list[index + 1].is_a?(Menu::Divider))
      end
      list.map(&:to_hash)
    end

    def authorized?
      children_hash.any?
    end
  end
end
