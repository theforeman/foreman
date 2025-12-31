require 'test_helper'
require Rails.root.join('db/migrate/20251229071811_remove_grub_template.rb')

class RemoveGrubTemplateTest < ActiveSupport::TestCase
  let(:migration) { RemoveGrubTemplate.new }

  setup do
    @pxe_grub_kind = TemplateKind.find_or_create_by!(name: 'PXEGrub')

    @template = ProvisioningTemplate.create!(
      name: 'Test PXEGrub Template',
      template: 'test template content',
      template_kind: @pxe_grub_kind,
      snippet: false,
      locked: true
    )
  end

  test "removes PXEGrub template kind and all templates" do
    assert TemplateKind.exists?(name: 'PXEGrub')
    assert Template.exists?(id: @template.id)

    migration.up

    assert_not TemplateKind.exists?(name: 'PXEGrub')
    assert_not Template.exists?(id: @template.id)
  end

  test "removes locked templates" do
    assert @template.locked?

    migration.up

    assert_not Template.exists?(id: @template.id)
  end

  test "removes os_default_templates associated with PXEGrub kind" do
    os = FactoryBot.create(:operatingsystem)
    os_default = OsDefaultTemplate.create!(
      operatingsystem: os,
      template_kind: @pxe_grub_kind,
      provisioning_template: @template
    )

    assert OsDefaultTemplate.exists?(id: os_default.id)

    migration.up

    assert_not OsDefaultTemplate.exists?(id: os_default.id)
    assert Operatingsystem.exists?(id: os.id)
  end

  test "removes template_combinations (hostgroup associations)" do
    hostgroup = FactoryBot.create(:hostgroup)
    combination = TemplateCombination.create!(
      provisioning_template: @template,
      hostgroup: hostgroup
    )

    assert TemplateCombination.exists?(id: combination.id)

    migration.up

    assert_not TemplateCombination.exists?(id: combination.id)
    assert_not Template.exists?(id: @template.id)
    assert Hostgroup.exists?(id: hostgroup.id)
  end

  test "templates with hostgroup associations cannot be deleted without bypass" do
    hostgroup = FactoryBot.create(:hostgroup)
    combination = TemplateCombination.create!(
      provisioning_template: @template,
      hostgroup: hostgroup
    )

    assert TemplateCombination.exists?(id: combination.id)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      @template.destroy!
    end

    assert Template.exists?(id: @template.id)
    assert TemplateCombination.exists?(id: combination.id)
  end

  test "removes multiple PXEGrub templates" do
    template2 = ProvisioningTemplate.create!(
      name: 'Test PXEGrub Template 2',
      template: 'test content 2',
      template_kind: @pxe_grub_kind,
      snippet: false,
      locked: true
    )

    assert_equal 2, Template.where(template_kind_id: @pxe_grub_kind.id).count

    migration.up

    assert_not Template.exists?(id: @template.id)
    assert_not Template.exists?(id: template2.id)
    assert_not TemplateKind.exists?(name: 'PXEGrub')
  end

  test "migration is irreversible" do
    assert_raises(ActiveRecord::IrreversibleMigration) do
      migration.down
    end
  end
end
