desc 'Apipie cache specific tasks'
namespace :apipie do
  desc 'Generate cache index'
  task 'cache:index' do |t, args|
    ENV['cache_part'] = 'index'
    Rake::Task['apipie:cache'].invoke
  end

  # when building just the cache index
  # copy all the prebuilt plugin resources to the cache
  Rake::Task['apipie:cache'].enhance do
    if ENV['cache_part'] == 'index'
      require 'fileutils'
      cache_path = File.expand_path('./public/apipie-cache')
      FileUtils.cp_r(Dir.glob(File.join(cache_path, 'plugin/*/*')).sort, cache_path)
    end
  end
end
