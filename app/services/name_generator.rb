class NameGenerator
  GENERATOR_TYPES = {
    'Off' => _('Off'),
    'Random-based' => _('Random-based'),
    'MAC-based' => _('MAC-based')
  }.freeze

  def self.random_based?
    Setting[:name_generator_type] =~ /^Random/i
  end
  delegate :random_based?, :to => :class

  def self.mac_based?
    Setting[:name_generator_type] =~ /^MAC/i
  end
  delegate :mac_based?, :to => :class

  def initialize
    @mac_generator = Deacon::MacGenerator.new
    @random_generator = Deacon::RandomGenerator.new
  end

  def next_mac_name(mac)
    if mac_based? && mac
      @mac_generator.generate(mac).join('-').downcase
    else
      ''
    end
  end

  def next_random_name
    if random_based?
      self.register, firstname, lastname = @random_generator.generate(self.register)
      [firstname, lastname].join('-').downcase
    else
      ''
    end
  end

  def register
    index = Rails.cache.fetch("name_generator_register")
    unless index
      index = self.register = Deacon::RandomGenerator.random_initial_seed
      Rails.logger.debug "Generated new randomized name generator register: #{index}"
    end
    index
  end

  def register=(value)
    Rails.cache.write("name_generator_register", value)
    value
  end
end
