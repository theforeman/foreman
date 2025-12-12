# Override validate_email gem's EmailValidator with Foreman's implementation.
# The openid_connect gem depends on validate_email which provides its own
# EmailValidator in ActiveModel::Validations namespace. We need Foreman's
# custom validator (with length checking and single-word domain support).
#
# Load Foreman's validator and assign it to the namespace Rails uses.
require Rails.root.join('app/validators/email_validator')
ActiveModel::Validations::EmailValidator = EmailValidator
