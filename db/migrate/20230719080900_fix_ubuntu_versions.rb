class FixUbuntuVersions < ActiveRecord::Migration[6.0]
  def up
    # For every Ubuntu operating system with a set minor version we
    #   * Check if there is already an operating system present with the same major and minor version combined in the major field
    #   * If not, we update the version
    Operatingsystem.where('name ~* :name', name: 'ubuntu')
                    .merge(Operatingsystem.where.not(minor: [nil, ''])).each do |os|
      if !Operatingsystem.where('name ~* :name', name: 'ubuntu').merge(Operatingsystem.where(major: "#{os.major}.#{os.minor}")).merge(Operatingsystem.where(minor: [nil, ''])).first
        os.update(major: "#{os.major}.#{os.minor}", minor: nil)
      end
    end
end

