class AddUniquenessToPuppetclassName < ActiveRecord::Migration[5.1]
  def up
    names = Puppetclass.group(:name).count.select { |key, value| value > 1 }.keys
    unless names.empty?
      names.each do |name|
        classes = Puppetclass.where :name => name
        say "#{classes.count} Puppet classes with duplicate name detected: #{name}"
      end
      raise "Please make sure there are no duplicate Puppet classes before continuing."
    end

    remove_index :puppetclasses, :name
    add_index :puppetclasses, :name, :unique => true
  end

  def down
    remove_index :puppetclasses, :name
    add_index :puppetclasses, :name
  end
end
