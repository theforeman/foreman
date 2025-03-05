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

  task :drop => :environment do
    compute_resources = ComputeResource.unscoped.where(type: 'Foreman::Model::Ovirt')

    exit_if_no_resources if compute_resources.empty?

    pretend_mode = Foreman::Cast.to_bool(ENV['OVIRT_PRETEND'])
    assume_yes = Foreman::Cast.to_bool(ENV['OVIRT_SKIP_CONFIRM'])

    if pretend_mode
      User.as_anonymous_admin do
        simulate_cleanup(compute_resources)
      end
    end

    prompt_user_confirmation(compute_resources) unless assume_yes

    User.as_anonymous_admin do
      perform_cleanup(compute_resources)
    end

    finalize_cleanup
  end

  def simulate_cleanup(compute_resources)
    puts "\nRunning in pretend mode. Following actions would be performed:"

    compute_resources.each do |cr|
      puts "Remove '#{cr.name} [#{cr.id}]' compute resource"

      puts "\nDissacociate the following hosts:"
      cr.hosts.each do |host|
        puts "- #{host.name} [#{host.id}]"
      end

      puts "\nUpdate the following host groups:"
      cr.hostgroups.each do |hg|
        puts "- '#{hg.name}' [#{hg.id}]"
      end

      puts "\nRemove the following compute profiles:"
      cr.compute_profiles.each do |cp|
        puts "- '#{cp.name}' [#{cp.id}]"
      end

      puts "\nRemove the following images:"
      cr.images.each do |image|
        puts "- '#{image.name}' [#{image.id}]"
      end
    end

    exit 0
  end

  def perform_cleanup(compute_resources)
    puts "\nStarting Ovirt drop ..."

    compute_resources.each do |cr|
      puts "Processing data for '#{cr.name}' compute resource."

      cr.hosts.each do |host|
        puts "Disassociating host '#{host.name}' from the compute resource."
        host.disassociate!
      end

      puts "Removing compute resources and compute profiles from host groups."
      cr.hostgroups.update_all(compute_resource_id: nil, compute_profile_id: nil)

      puts "Removing '#{cr.name}' compute resource."
      cr.destroy
    end
  end

  def prompt_user_confirmation(compute_resources)
    puts <<~ASK_PROMPT
      !!! WARNING !!! This operation is irreversible."

      Affected compute resource(s): #{compute_resources.map(&:name).join(', ')}."
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
