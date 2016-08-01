module ReactjsHelper
  def mount_react_component(name, selector, data)
    javascript_tag defer: 'defer' do
      "$(tfm.reactMounter.mount('#{name}', '#{selector}', #{data}));".html_safe
    end
  end
end
