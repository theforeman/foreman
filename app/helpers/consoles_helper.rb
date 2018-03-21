module ConsolesHelper
  def webmks_assets_provided?
    Rails.root.join('public', 'webmks').exist?
  end
end
