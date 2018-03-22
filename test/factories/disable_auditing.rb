FactoryBot.define do
  # Default to disabling auditing when saving new models to reduce database
  # work and speed up tests. Add the :with_auditing global trait to enable it.
  trait :with_auditing do
    before(:create) do |instance, evaluator|
      instance.instance_variable_set(:@_factory_bot_with_auditing, true)
    end
  end

  to_create do |instance|
    with_auditing = !!instance.instance_variable_get(:@_factory_bot_with_auditing) # default to no auditing
    if instance.respond_to?(:without_auditing) && !with_auditing
      instance.without_auditing { instance.save! }
    else
      instance.save!
    end
  end
end
