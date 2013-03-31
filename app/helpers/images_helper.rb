module ImagesHelper
  def image_field f
    return unless @compute_resource.capabilities.include?(:image)
    images = @compute_resource.available_images
    if images.any?
      return select_f(f, :uuid, images.to_a.sort! { |a, b| a.name.downcase <=> b.name.downcase }, :id, :name, {}, :label => 'Image')
    else
      text_f f, :uuid, :label => "Image ID", :help_inline => "Image ID as provided by the compute resource, e.g. ami-.."
    end
  end
end
