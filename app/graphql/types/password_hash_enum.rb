module Types
  class PasswordHashEnum < BaseEnum
    ::PasswordCrypt::ALGORITHMS.each do |alg, val|
      value alg.tr('-', '_'), value: alg
    end
  end
end
