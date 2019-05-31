# frozen_string_literal: true

class CreateRegistrationFacets < ActiveRecord::Migration[5.1]
  def change
    create_table :registration_facets do |t|
      t.references :host, null: false, foreign_key: true, index: true, unique: true
      t.string :jwt_secret, index: { unique: true }, null: false

      t.timestamps null: false
    end
  end
end
