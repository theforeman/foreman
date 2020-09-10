class AddUniqueToOperatingsystemsTitle < ActiveRecord::Migration[4.2]
  def up
    dups = Operatingsystem.all.group_by(&:fullname).values.keep_if { |ary| ary.length > 1 }
    dups.each do |systems|
      systems.sort! { |a, b| b.hosts_count <=> a.hosts_count }.shift
      systems.each_with_index do |os, index|
        os.name = os.name + "-#{index + 1}"
        os.save!
      end
    end

    duplicities = Operatingsystem.all.group_by(&:title).values.keep_if { |ary| ary.length > 1 }
    duplicities.each do |systems|
      systems.each do |os|
        os.description = os.fullname
        os.save!
      end
    end

    add_index :operatingsystems, :title, :unique => true
    change_column_null :operatingsystems, :name, false
    add_index :operatingsystems, [:name, :major, :minor], :unique => true
  end

  def down
    remove_index :operatingsystems, :title
    change_column_null :operatingsystems, :name, true
    remove_index :operatingsystems, [:name, :major, :minor]
  end
end
