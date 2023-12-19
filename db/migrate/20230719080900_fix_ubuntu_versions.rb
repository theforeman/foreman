class FixUbuntuVersions < ActiveRecord::Migration[6.0]
  def up
    # For every Ubuntu operating system with a set minor version we
    #   * Check if there is already an operating system present with the same major and minor version combined in the major field
    #   * If not, we update the version
    Operatingsystem.where(name: 'Ubuntu')
      .where('operatingsystems.major ~* ?', '^\d*$')
      .where.not(minor: [nil, ''])
      .where('o3.id IS NULL')
      .joins("left outer join operatingsystems o3 on o3.major like concat(operatingsystems.major, '.', operatingsystems.minor)")
      .update_all('major = concat(operatingsystems.major, \'.\', operatingsystems.minor), minor = \'\'')
  end
end
