require 'foreman/deployments/dsl'

Foreman::Deployments::DSL.define do
  stack :db do
    hostgroup :db do
      param :db_password
      param(:db_api_url) { default_value "<%= compute_url() %>" }
      override :password_override do
        name "password_override"
        key "$postgress::password"
        value "<%= get_param('db', 'db_hostgroup', 'db_password') %>"
      end
      puppetclass :postgres
    end

    host :db do
      count 1..1
      puppet_run(:db1) >> puppet_run(:db2)
    end
  end
end
