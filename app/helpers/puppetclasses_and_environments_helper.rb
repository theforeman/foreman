module PuppetclassesAndEnvironmentsHelper
  def class_update_text pcs, env
    if pcs.empty?
      "Empty environment"
    elsif pcs == ["_destroy_"]
      "Deleted environment"
    elsif pcs.delete "_destroy_"
      "Deleted environment #{env} and " + pcs.to_sentence
    else
      pcs.to_sentence
    end
  end
end
