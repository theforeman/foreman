# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# This file must remain idempotent.
#
# Please ensure that all templates are submitted to community-templates, then they will be synced in.

# define all helpers here
seeder = ForemanSeeder.new
seeder.execute
