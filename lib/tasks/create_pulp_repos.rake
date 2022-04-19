namespace :katello do
  desc <<-DESC
    Create on Satellite's internal Pulp instance all repositories known to Foreman/Katello. ENV variables:

      Optional:
        * LIFECYCLE_ENVIRONMENT : name or numeric ID of the Lifecycle Environment to limit repositories to
	* CONTENT_VIEW          : name or label or numeric ID of the Content View to limit repositories to
	* REPOSITORY            : numeric ID or pulp id of the repository to limit the selection to
	* VERBOSE               : be verbose (true or false[default])

      Examples:
	* rake katello:create_pulp_repos REPOSITORY=5  # Create on pulp the repository with numeric ID 5
        * rake katello:create_pulp_repos LIFECYCLE_ENVIRONMENT=someLCE CONTENT_VIEW="My Cool CV"  # Create on pulp the repositories belonging to this CV in this Environment
	* rake katello:create_pulp_repos   # Create on pulp ALL repositories known to katello/foreman


  DESC
  task :create_pulp_repos => ["environment", "dynflow:client"] do
    env = ENV['LIFECYCLE_ENVIRONMENT']
    content_view = ENV['CONTENT_VIEW']
    repository = ENV['REPOSITORY']
    if ENV['VERBOSE']
      verbose = ENV['VERBOSE'].downcase == "true"
    else
      verbose = false
    end
    User.current = User.anonymous_api_admin

    options = {}

    repolist = Katello::Repository.all

    puts "::DEBUG:: Starting out with #{repolist.count} repositories on the list. This list may be filtered before it's pushed to Pulp." if verbose

    if env
      # Look up by name first, then by ID if name doesn't work
      lce = Katello::KTEnvironment.find_by(:name => env)
      unless lce
	lce = Katello::KTEnvironment.find(env.to_i)
      end
      if lce
        previous_repolist_count = repolist.count
        repolist = repolist.select {|r| r.environment == lce}
        puts "::DEBUG:: Limiting repositories to the ones in Lifecycle Environment #{lce.name} (ID #{lce.id}). Count was #{previous_repolist_count}, now #{repolist.count}" if verbose
        lce = lce.name
      else
        puts "::WARNING:: Lifecycle Environment #{env} not found. I will consider all Lifecycle Environments instead."
        lce = "#{env} [no matches]"
      end
    end

    if content_view
      # Look up by name first, then label, then ID
      cv = Katello::ContentView.find_by(:name => content_view)
      unless cv
	cv = Katello::ContentView.find_by(:label => content_view)
	unless cv
	  cv = Katello::ContentView.find(content_view.to_i)
	end
      end
      if cv
        previous_repolist_count = repolist.count
        repolist = repolist.select {|r| r.content_view == cv}
        puts "::DEBUG:: Limiting repositories to the ones in Content View #{cv.name} (ID #{cv.id}). Count was #{previous_repolist_count}, now #{repolist.count}" if verbose
        cv = cv.name
      else
        puts "::WARNING:: Content View #{content_view} not found. I will consider all Content Views instead." if verbose == "true"
        cv = "#{content_view} [no matches]"
      end
    end

    if repository
      # Look up by numeric ID (Katello) then by pulp_id (UUID)
      repo = Katello::Repository.find(repository.to_i)
      unless repo
	repo = Katello::Repository.find_by(:pulp_id => repository)
      end
      if repo
        previous_repolist_count = repolist.count
        repolist = repolist.select {|r| r == repo}
        puts "::DEBUG:: Limiting repositories to the ones equal to Repository #{repo.name} (ID #{repo.id}). Count was #{previous_repolist_count}, now #{repolist.count}" if verbose
        repo = repo.label
      else
        puts "::WARNING:: Repository #{repository} not found. I will consider all Repositories instead." if verbose == "true"
        repo = "#{repository} [no matches]"
      end
    end

    if verbose
      puts "Will now push to pulp #{repolist.count} repositories after applying the filters below:"
      puts "  environment...: #{lce}" if lce
      puts "  content_view..: #{cv}" if cv
      puts "  repository....: #{repo}" if repo
    end
    internal_capsule = SmartProxy.find(1)
    puts "::INFO:: Total repositories to be created on Pulp: #{repolist.count}. This may take a while."
    done_count = 0
    puts ""
    if internal_capsule.pulp3_enabled?
      repolist.each do
        |onerepo|
        task = ForemanTasks.async_task(Actions::Pulp3::Repository::Create, onerepo, internal_capsule)  # pulp3 accepts a "force" param
        done_count +=1
        printf "\rRepos scheduled: #{done_count}" if done_count % 10 == 0
      end
    else
      repolist.each do
        |onerepo|
        task = ForemanTasks.async_task(Actions::Pulp::Repository::Create, onerepo, internal_capsule)
        done_count +=1
        printf "\rRepos scheduled: #{done_count}" if done_count % 10 == 0
      end
    end
    puts "  *** #{repolist.count} tasks triggered asynchronously. ***"
  end
end
