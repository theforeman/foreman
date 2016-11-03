class TurnGlobalParametersToLookupKeys < ActiveRecord::Migration
  class Parameter < ActiveRecord::Base
  end

  def up
    references = {}
    keys = {}
    all_params = select_all('select name, value, reference_id, type, hidden_value from parameters')
    all_params.group_by { |p| p['type'] }.each do |type, params|
      references[type]||= [] unless type == 'CommonParameter'

      params.each do |param|
        references[type].push param['reference_id'] unless type == 'CommonParameter'
        keys[param['name']] ||= []
        keys[param['name']].push param
      end
    end

    get_reference_ids(references)
    create_global_lookup_key(keys, references)
    Parameter.delete_all
  end

  def create_global_lookup_key(keys, references)
    keys.each do |key, values|
      hidden_value = values.any?{|v| v['hidden_value'] == "t"}
      global_lk = GlobalLookupKey.where(:key => key, :hidden_value => hidden_value).first_or_initialize

      common = values.detect { |p| p['type'] == 'CommonParameter' }
      if common
        global_lk.default_value = common['value']
        global_lk.should_be_global = true
        values.delete(common)
      end

      create_lookup_values(values, global_lk, references)
      global_lk.save!
    end
  end

  def get_reference_ids(references)
    references.each do |key, ids|
      matcher_key = key.split('Parameter')[0]
      case matcher_key
        when 'Os'
          matcher_key = 'Operatingsystem'
        when 'Group'
          matcher_key = 'Hostgroup'
      end
      references[key] = matcher_key.constantize.where(:id => ids.uniq).to_a
    end
  end

  def create_lookup_values(values, key, references)
    values.each do |param|
      key.override = true
      LookupValue.create(:lookup_key => key, :value => param['value'],
                         :match => references[param['type']].detect { |ref| ref.id.to_s == param['reference_id'] }.try(:lookup_value_match))
    end
  end

  def down
    references = {}
    GlobalLookupKey.unscoped.each do |global|
      global.lookup_values.each do |lookup_value|
        type, name = lookup_value.match.split('=')
        references[type] ||= []
        references[type].push name
      end
    end

    references.each do |type, names|
      reference_class = case type
                          when 'os'
                            Operatingsystem
                          when 'fqdn'
                            Host::Managed
                          else
                            type.classify.constantize
                        end
      lookup_value_matchers = []
      names.each {|name| lookup_value_matchers << "#{type}=#{name}"}
      references[type] = reference_class.where(:lookup_value_matcher =>  lookup_value_matchers)
    end

    create_parameters(references)
    GlobalLookupKey.destroy_all
  end

  def create_parameters(references)
    GlobalLookupKey.unscoped.each do |global|
      if global.should_be_global
        original_param = Parameter.new(:name => global.key, :value => global.default_value, :hidden_value => global.hidden_value?)
        original_param.type = 'CommonParameter'
        original_param.save!
      end
      global.lookup_values.each do |lookup_value|
        reference = lookup_value.match.split('=')[0]
        obj = references[reference].detect { |ref| ref.lookup_value_match == lookup_value.match }
        original_param = Parameter.new(:name => global.key, :value => lookup_value.value, :reference_id => obj.id, :hidden_value => global.hidden_value?)
        original_param.type = case reference
                                when 'hostgroup'
                                  'GroupParameter'
                                when 'fqdn'
                                  'HostParameter'
                                else
                                  "#{reference.capitalize}Parameter"
                              end
        original_param.save!
      end
    end
  end
end
