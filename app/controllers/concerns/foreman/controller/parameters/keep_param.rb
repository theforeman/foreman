# Used in *_params methods to note an input parameter, yield to a block that then
# filters the parameters and then set the parameter back in the filtered hash,
# bypassing the filtering mechanism.
#
# This helps when passing hashes of data without a clear schema through filtering,
# working around https://github.com/rails/rails/issues/9454.
module Foreman::Controller::Parameters::KeepParam
  def keep_param(params, top_level_hash, *keys)
    old_params = keys.inject({}) do |op,(key,val)|
      params[top_level_hash].has_key?(key) ? op.update(key => params[top_level_hash].delete(key)) : op
    end
    yield.update old_params
  end
end
