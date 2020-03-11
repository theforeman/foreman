module Types
  class Mutation < BaseObject
    graphql_name 'Mutation'

    field :signInUser, mutation: Mutations::SignInUser

    field :create_model, mutation: Mutations::Models::Create
    field :update_model, mutation: Mutations::Models::Update
    field :delete_model, mutation: Mutations::Models::Delete

    field :create_host, mutation: Mutations::Hosts::Create

    field :create_medium, mutation: Mutations::Media::Create
    field :update_medium, mutation: Mutations::Media::Update
    field :delete_medium, mutation: Mutations::Media::Delete

    field :create_bookmark, mutation: Mutations::Bookmarks::Create
    field :update_bookmark, mutation: Mutations::Bookmarks::Update
    field :delete_bookmark, mutation: Mutations::Bookmarks::Delete

    include ::Foreman::Plugin::GraphqlPluginFields
    realize_plugin_mutation_extensions
  end
end
