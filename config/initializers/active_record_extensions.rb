class ActiveRecord::Base
  extend System::Systemmix
  include HasManyCommon
  include StripWhitespace
end