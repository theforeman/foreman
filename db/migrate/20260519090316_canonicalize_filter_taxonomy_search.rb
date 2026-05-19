class CanonicalizeFilterTaxonomySearch < ActiveRecord::Migration[7.0]
  class MigrationFilter < ApplicationRecord
    self.table_name = 'filters'
  end

  ONLY_ORG = /\A\(organization_id \^ \(([\d,\s]+)\)\)\z/
  ONLY_LOC = /\A\(location_id \^ \(([\d,\s]+)\)\)\z/
  ORG_AND_LOC = /\A\(\(organization_id \^ \(([\d,\s]+)\)\) AND \(location_id \^ \(([\d,\s]+)\)\)\)\z/

  def up
    rewritten = 0
    skipped = 0

    MigrationFilter.where.not(taxonomy_search: nil).find_each do |filter|
      canonical = canonicalize(filter.taxonomy_search)

      if canonical.nil?
        skipped += 1
        next
      end

      next if canonical == filter.taxonomy_search

      filter.update_column(:taxonomy_search, canonical)
      rewritten += 1
    end

    say "Canonicalized #{rewritten} filter(s), skipped #{skipped} with unrecognized format"
  end

  def down
    # no-op: canonical ordering is semantically equivalent
  end

  private

  def canonicalize(search)
    case search
    when ONLY_ORG
      build_org_only(parse_ids(::Regexp.last_match(1)))
    when ONLY_LOC
      build_loc_only(parse_ids(::Regexp.last_match(1)))
    when ORG_AND_LOC
      build_org_and_loc(parse_ids(::Regexp.last_match(1)), parse_ids(::Regexp.last_match(2)))
    end
  end

  def parse_ids(id_string)
    id_string.split(',').map(&:strip).reject(&:blank?).map(&:to_i).uniq.sort
  end

  def build_org_only(ids)
    "(organization_id ^ (#{ids.join(',')}))"
  end

  def build_loc_only(ids)
    "(location_id ^ (#{ids.join(',')}))"
  end

  def build_org_and_loc(org_ids, loc_ids)
    "((organization_id ^ (#{org_ids.join(',')})) AND (location_id ^ (#{loc_ids.join(',')})))"
  end
end
