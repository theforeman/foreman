import $ from 'jquery';

export function resourceTypeChanged({ dataset, value }) {
  $.ajax({
    url: dataset.url,
    data: {
      resource_type: value,
    },
    dataType: 'script',
  });
}

export function unlimitedChanged(checkbox) {
  const isChecked = $(checkbox).prop('checked');
  $('#search').prop('disabled', isChecked);
}

export function overrideTaxonomyChecked(checkbox) {
  const isChecked = $(checkbox).prop('checked');
  const data = $('#filter_resource_type').data();
  const allowOrganizations = data.allow_organizations;
  const allowLocations = data.allow_locations;

  $('li a[href="#organizations"]').toggle(isChecked && allowOrganizations);
  $('li a[href="#locations"]').toggle(isChecked && allowLocations);
}
