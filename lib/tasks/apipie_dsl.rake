desc 'Apipie DSL cache specific tasks'
namespace :apipie_dsl do
  desc 'Generate cache index for all languages (override with FOREMAN_APIPIE_LANGS environment variable)'
  task 'cache:index' do |t, args|
    ENV['cache_part'] = 'index'
    Rake::Task['apipie_dsl:cache'].invoke
  end

  # when building just the cache index
  # copy all the prebuilt plugin resources to the cache
  Rake::Task['apipie_dsl:cache'].enhance do
    if ENV['cache_part'] == 'index'
      require 'fileutils'
      cache_path = File.expand_path('./public/apipie-dsl-cache')
      FileUtils.cp_r(Dir.glob(File.join(cache_path, 'plugin/*/*')).sort, cache_path)
    end
  end
end
