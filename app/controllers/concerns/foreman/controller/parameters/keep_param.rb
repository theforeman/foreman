# Used in *_params methods to note an input parameter, yield to a block that then
# filters the parameters and then set the parameter back in the filtered hash,
# bypassing the filtering mechanism.
#
# This helps when passing hashes of data without a clear schema through filtering,
# working around https://github.com/rails/rails/issues/9454.
module Foreman::Controller::Parameters::KeepParam
  def keep_param(params, top_level_hash, *keys)
    old_params = detect_old_params params, top_level_hash, keys
    filtered = yield
    old_params.each do |key,val|
      # Restore the deleted (kept) keys to the filtered hash of params from the block
      filtered[key] = val.respond_to?(:to_h) ? val.to_h : val
      # Restore the deleted (kept) keys to the original params hash so it remains unchanged
      params[top_level_hash][key] = val
    end
    filtered
  end

  def detect_old_params(params, top_level_hash, keys)
    # Delete keys being kept from the `params` hash, so the block yielded to filters the others
    keys.inject({}) do |op,(key,val)|
      if params[top_level_hash].try!(:has_key?, key)
        op[key] = params[top_level_hash].delete(key)
        op[key].permit! if op[key].is_a?(ActionController::Parameters)
      end
      op
    end
  end
end
