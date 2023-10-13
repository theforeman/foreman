class IntroduceHostProductsReport < ActiveRecord::Migration[6.1]
  def up
    token = SecureRandom.base64(5)
    ReportTemplate.unscoped.find_by(name: "Host - Installed Products")&.update_columns(:name => "Host - Installed Products #{token}")
  end

  def down
    ReportTemplate.unscoped.find_by(name: "Host - Installed Products")&.destroy
  end
end
