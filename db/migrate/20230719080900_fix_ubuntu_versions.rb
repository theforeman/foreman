class FixUbuntuVersions < ActiveRecord::Migration[6.0]
  def up
    # For every Ubuntu operating system with a major version and a minor version in the format "<digits>(.<digits>)",
    #   * We check if there is already an operating system present with a major version of
    #     "<major>.<first_place_of_minor>" and a minor version of "<second_place_of_minor_or_empty>".
    #   * If not, we update the major version of the operating system to "<major>.<first_place_of_minor>" and the minor
    #     version to "<second_place_of_minor_or_empty>".
    Operatingsystem.where(name: 'Ubuntu')
      .where('operatingsystems.major ~* ?', '^\d*$')
      .where('operatingsystems.minor ~* ?', '^\d\d(\.\d)?$')
      .where('o2.id IS NULL')
      .joins("left outer join operatingsystems o2 " \
              "on o2.name = operatingsystems.name " \
              "and o2.major = concat(operatingsystems.major, '.', split_part(operatingsystems.minor, '.', 1)) " \
              "and o2.minor = split_part(operatingsystems.minor, '.', 2)")
      .update_all("major = concat(operatingsystems.major, '.', split_part(operatingsystems.minor, '.', 1)), " \
                  "minor = split_part(operatingsystems.minor, '.', 2)")
  end
end
