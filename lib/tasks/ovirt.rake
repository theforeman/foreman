namespace :ovirt do
  desc <<~END_DESC
    Remove all oVirt / RHV compute resources & profiles from Foreman.
    Hosts associated with these compute resources will be disassociated and kept.
    Host groups with oVirt compute resources & profiles will have their compute resource and compute profile removed.
    Compute profiles, images, and other resources will be removed.

    Use OVIRT_PRETEND=true to simulate the operation without making any changes.
    Use OVIRT_SKIP_CONFIRM=true to skip the confirmation prompt.

    Examples:
      # foreman-rake ovirt:drop
      # OVIRT_SKIP_CONFIRM=true foreman-rake ovirt:drop
      # OVIRT_PRETEND=true foreman-rake ovirt:drop
  END_DESC

  task drop: :environment do
    service = ComputeResourceCleaner.new(klass: 'Foreman::Model::Ovirt')
    exit_if_no_resources if service.resource_ids.empty?

    pretend_mode = Foreman::Cast.to_bool(ENV['OVIRT_PRETEND'])
    assume_yes = Foreman::Cast.to_bool(ENV['OVIRT_SKIP_CONFIRM'])

    if pretend_mode
      User.as_anonymous_admin do
        service.simulate
        exit 0
      end
    end

    prompt_user_confirmation unless assume_yes

    User.as_anonymous_admin do
      service.run!
    end

    finalize_cleanup
  end

  def prompt_user_confirmation
    puts <<~ASK_PROMPT
      !!! WARNING !!! This operation is irreversible."

      - This task will remove all oVirt / RHV compute resources from Foreman."
      - All hosts associated with these compute resources will be disassociated and kept."
      - All host groups with compute resources will have their compute resource and compute profile removed."
      - Compute profiles, images and other resources associated with the compute resources will be removed."

      Are you sure you want to continue? (yes/no)
    ASK_PROMPT

    answer = $stdin.gets.chomp.downcase

    unless answer == "yes"
      puts "Aborting task."
      exit 1
    end
  end

  def exit_if_no_resources
    puts "No 'Foreman::Model::Ovirt' compute resources found."
    puts "Nothing to do, exiting."
    exit 0
  end

  def finalize_cleanup
    puts 'oVirt cleanup was successfully completed.'
    puts 'Exiting.'
    exit 0
  end
end
