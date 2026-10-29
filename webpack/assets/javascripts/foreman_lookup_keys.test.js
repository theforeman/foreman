import $ from 'jquery';
import { serializeLookupValues } from './foreman_lookup_keys';

jest.unmock('jquery');
jest.unmock('./foreman_lookup_keys');

const row = (index, fields) => `<tr class="matchers"><td>${fields}
  <input class="match" name="key[lookup_values_attributes][${index}][match]" value="hostgroup=db${index}">
  <textarea name="key[lookup_values_attributes][${index}][value]">4</textarea>
  <input type="hidden" name="key[lookup_values_attributes][${index}][omit]" value="0">
  <input type="checkbox" name="key[lookup_values_attributes][${index}][omit]" checked>
  </td></tr>`;

beforeEach(() => {
  document.body.innerHTML = `<form data-lookup-values-json="true">
    <input name="_method" value="patch">
    <div class="children_fields lookup_values">
      <input class="lookup_values_json" name="key[lookup_values_json]">
      <table><tbody>${row(
        0,
        `
        <input type="hidden" name="key[lookup_values_attributes][0][id]" value="12">
        <input type="hidden" name="key[lookup_values_attributes][0][_destroy]" value="1">
      `
      )}${row(1, '')}</tbody></table>
      <div class="lookup_values_fields_template"><table>${row(
        'new',
        ''
      )}</table></div>
    </div>
  </form>`;
});

it('serializes rows, includes removed rows, excludes the template and disables nested fields', () => {
  const form = document.querySelector('form');
  form.querySelector('tr.matchers').style.display = 'none';
  // The existing form handler builds matches before the delegated serializer.
  $(form).on('submit', () => {
    form.querySelector('.match').value = 'hostgroup=updated';
  });
  form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));

  expect(JSON.parse(form.querySelector('.lookup_values_json').value)).toEqual([
    { match: 'hostgroup=updated', omit: true, id: '12', _destroy: '1' },
    { match: 'hostgroup=db1', omit: true },
  ]);
  const submitted = new FormData(form);
  expect(Array.from(submitted.keys())).toEqual([
    '_method',
    'key[lookup_values_json]',
  ]);
  form
    .querySelectorAll('[name*="[lookup_values_attributes]"]')
    .forEach(input => {
      expect(input.disabled).toBe(true);
    });
});

it('serializes an empty override list', () => {
  const form = document.querySelector('form');
  form.querySelector('tbody').innerHTML = '';
  serializeLookupValues({ target: form });
  expect(form.querySelector('.lookup_values_json').value).toBe('[]');
});

it('leaves nested puppet and host forms on nested attributes without opting in', () => {
  const form = document.querySelector('form');
  form.removeAttribute('data-lookup-values-json');
  const jsonField = form.querySelector('.lookup_values_json');
  jsonField.value = 'untouched';
  form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
  serializeLookupValues({ target: form });
  expect(jsonField.value).toBe('untouched');
  jsonField.remove();
  form.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
  serializeLookupValues({ target: form });
  form
    .querySelectorAll('[name*="[lookup_values_attributes]"]')
    .forEach(input => {
      expect(input.disabled).toBe(false);
    });
  expect(Array.from(new FormData(form).keys())).toContain(
    'key[lookup_values_attributes][0][value]'
  );
});

it('does not serialize omitted values and reads values again after repeated submits and omit toggles', () => {
  const form = document.querySelector('form');
  const checkbox = form.querySelector('input[type="checkbox"]');
  const valueField = form.querySelector('textarea');
  const serializedRow = () =>
    JSON.parse(form.querySelector('.lookup_values_json').value)[0];
  valueField.disabled = true;
  serializeLookupValues({ target: form });
  expect(serializedRow()).not.toHaveProperty('value');
  serializeLookupValues({ target: form });
  expect(serializedRow()).not.toHaveProperty('value');

  checkbox.checked = false;
  valueField.disabled = false; // toggleOmitValue enables the value control.
  valueField.value = '8';
  serializeLookupValues({ target: form });
  expect(serializedRow()).toMatchObject({ value: '8', omit: false });
  expect(valueField.disabled).toBe(true);
  serializeLookupValues({ target: form });
  expect(serializedRow()).toMatchObject({ value: '8', omit: false });

  checkbox.checked = true;
  serializeLookupValues({ target: form });
  expect(serializedRow()).not.toHaveProperty('value');
});
