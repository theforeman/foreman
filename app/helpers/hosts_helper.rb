module HostsHelper
  def last_compile_column(record)
    time_ago_in_words record.last_compile.getlocal unless record.last_compile.nil?
  end
  def root_pass_form_column(record, field_name)
      password_field_tag field_name, record.root_pass
  end

# method that reformats the hostname column by adding the status icons
  def name_column(record)
    return image_tag("hosts/attention_required.png", :size => "18x18",
                     :title => "Pending Installation") + " " + record.name  if record.build

    os_fact=record.fact('kernel')[0]
    os=os_fact.value unless os_fact.nil?
    return image_tag("hosts/warning.png", :size => "18x18",
                     :title => "No Inventory Data") + " " + record.name if os.nil?

    return image_tag("hosts/#{os}.jpg", :size => "18x18", :title => os) + " " + record.name
  end

end
