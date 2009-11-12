require 'yaml'

module Chart
  class Theme
    class ThemeNotFound < RuntimeError; end
    
    @@theme_files = ["#{File.dirname(__FILE__)}/../themes.yml"]

    attr_accessor :colors
    attr_accessor :bar_colors
    attr_accessor :background
    attr_accessor :chart_background
    
    def self.load(theme_name)
      theme = new(theme_name)
    end
    
    def self.theme_files
      @@theme_files
    end
    
    # Allows you to specify paths for custom theme files in YAML format
    def self.add_theme_file(file)
      @@theme_files << file
    end
    
    def initialize(theme_name)
      themes = {}
      @@theme_files.each {|f| themes.update YAML::load(File.open(f))}
      theme = themes[theme_name]
      if theme
        self.colors = theme[:colors]
        self.bar_colors = theme[:bar_colors]
        self.background = theme[:background]
        self.chart_background = theme[:chart_background]
        self
      else
        raise(ThemeNotFound, "Could not locate the #{theme_name} theme ...")
      end
    end
    
    def to_options
      {:background => background, :chart_background => chart_background, :bar_colors => bar_colors.join(',')}
    end
  end
end