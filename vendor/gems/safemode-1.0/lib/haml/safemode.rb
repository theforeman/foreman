require 'haml'

module Haml  
  class Buffer
    class Jail < Safemode::Jail
      allow :push_script, :push_text, :_hamlout, :open_tag
    end
  end
end

module Haml  
  class Engine
    def precompile_for_safemode(filename, ignore_assigns = [], delegate_methods = [])        
        @precompiled.gsub!('\\','\\\\\\') # backslashes would disappear in compile_template/modul_eval, so we escape them
        
        <<-CODE 
          buffer = Haml::Buffer.new(#{options_for_buffer.inspect})
          local_assigns = local_assigns.merge :_hamlout => buffer
          
          handler = ActionView::TemplateHandlers::SafeHaml
          assigns = handler.valid_assigns(@template.assigns)
          methods = handler.delegate_methods(self)
          code = %Q(#{code});
          
          box = Safemode::Box.new(self, methods, #{filename.inspect}, 0)
          box.eval(code, assigns, local_assigns, &lambda{ yield })     
          buffer.buffer   
        CODE

        # preamble =  "buffer = Haml::Buffer.new(#{options_for_buffer.inspect})
        #              local_assigns = local_assigns.merge :_hamlout => buffer
        #              assigns = @template.assigns.reject{|key, value| #{ignore_assigns.inspect}.include?(key) };".gsub("\n", ';')
        #             
        # postamble = "box = Safemode::Box.new(self, #{delegate_methods.inspect})
        #              box.eval(code, assigns, local_assigns, &lambda{ yield })
        #              buffer.buffer".gsub("\n", ';')
        # 
        # preamble + "code = %Q(#{@precompiled});" + postamble
    end
  end
end