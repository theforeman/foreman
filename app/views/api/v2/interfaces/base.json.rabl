object @interface

attributes :id, :name, :ip, :mac
node :type do |i|
  i.class.humanized_name.downcase
end
