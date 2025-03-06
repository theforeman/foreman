class RenameAnsibleTowerFqdnToApiURL < ActiveRecord::Migration[7.0]
  def up
    Parameter.where(name: 'ansible_tower_fqdn').find_each do |parameter|
      parameter.update(
        name: 'ansible_tower_api_url',
        value: "https://#{parameter.value}/api/controller/v2"
      )
    end
  end

  def down
    Parameter.where(name: 'ansible_tower_api_url').find_each do |parameter|
      parameter.update(
        name: 'ansible_tower_fqdn',
        value: URI(parameter.value).host
      )
    end
  end
end
