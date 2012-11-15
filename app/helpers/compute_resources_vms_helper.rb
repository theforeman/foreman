module ComputeResourcesVmsHelper

  # little helper to help show VM properties
  def prop method, title = nil
    content_tag :tr do
      result = content_tag :td do
        title || method.to_s.humanize
      end
      result += content_tag :td do
        value = @vm.send(method) rescue nil
        case value
        when Fog::Compute::OpenStack::SecurityGroups
          security_groups = []
          value.each do |security_group|
            security_groups << security_group.name
          end
          security_groups.to_sentence    
        when Array
          value.to_sentence
        when Fog::Time, Time
          time_ago_in_words(value) + " ago"
        when nil
            "N/A"
        else
          value.to_s
        end
      end
      result
    end
  end

end
