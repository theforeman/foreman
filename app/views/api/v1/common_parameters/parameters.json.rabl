object @parameter

attributes :id, :value, :created_at, :updated_at
attribute :key => :name
node(:reference_id) { locals[:reference_id] }
node(:priority) { locals[:priority] }