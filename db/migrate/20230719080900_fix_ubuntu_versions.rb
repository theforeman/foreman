class FixUbuntuVersions < ActiveRecord::Migration[6.0]
  def up
    # For every Ubuntu operating system with a set minor version we
    #   * Check if there is already an operating system present with the same major and minor version combined in the major field
    #   * If not, we update the version
    Operatingsystem.where(name: 'Ubuntu').where.not(minor: [nil, '']).each do |os|
      unless Operatingsystem.find_by(name: 'Ubuntu', major: "#{os.major}.#{os.minor}", minor: [nil, ''])
        os.update(major: "#{os.major}.#{os.minor}", minor: nil)
      end
    end
  end
end
