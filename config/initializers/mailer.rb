ActionMailer::DeliveryJob.rescue_from(Net::SMTPSyntaxError) do |exception|
  raise exception
end
