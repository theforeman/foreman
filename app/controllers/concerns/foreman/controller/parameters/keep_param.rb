# Used in *_params methods to note an input parameter, yield to a block that then
# filters the parameters and then set the parameter back in the filtered hash,
# bypassing the filtering mechanism.
#
# This helps when passing hashes of data without a clear schema through filtering,
# working around https://github.com/rails/rails/issues/9454.
module Foreman::Controller::Parameters::KeepParam
  def keep_param(params, top_level_hash, *keys)
    # Delete keys being kept from the `params` hash, so the block yielded to filters the others
    old_params = keys.inject({}) do |op,(key,val)|
      params[top_level_hash].has_key?(key) ? op.update(key => params[top_level_hash].delete(key)) : op
    end

    # Restore the deleted (kept) keys to the filtered hash of params from the block
    filtered = yield.update(old_params)
    # Restore the deleted (kept) keys to the original params hash so it remains unchanged
    params[top_level_hash].update old_params
    filtered
  end
end
