module AuthSourceLdapsHelper

  def on_the_fly? authsource
    return false if authsource.new_record?
    authsource.onthefly_register?
  end

end
