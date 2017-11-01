jest.unmock('./foreman_navigation');
import $ from 'jquery';
import { init } from './foreman_navigation';

describe('initNavigation', () => {
  Object.defineProperty(window.location, 'pathname', {
    writable: true,
    value: '/locations/1/select',
  });
  const menuWithoutTaxonomies = `<div id="vertical-nav" class="nav-pf-vertical hover-secondary-nav-pf">    
         <ul class="list-group" >
           <li class="list-group-item secondary-nav-item-pf"
               data-target="location-secondary">  
             <a>
               <span class="list-group-item-value"> Location </span> 
             </a>
             <div id='location-secondary' class="nav-pf-secondary-nav">
               <div class="nav-item-pf-header">
                 <a class="secondary-collapse-toggle-pf", data-toggle="collapse-secondary-nav" ></a>
                 <span>Location</span>
               </div>
               <ul class="list-group">
                 <li class="list-group-item"><a id="menu_item_Any_Location"
                     data-id="aid_locations_clear" href="/locations/clear">
                  <span class="list-group-item-value">Any Location</span></a></li>
                 <div class="divider"></div>
                 <li class="list-group-item"><a id="menu_item_loc1"
                     data-id="aid_locations_3_select"
                     href="/locations/1/select"><span class="list-group-item-value">
                     Loc1</span></a></li>
               </ul>
             </div>  
           </li>
           <li class="list-group-item secondary-nav-item-pf"
             data-target="organization-secondary">  
             <a>
               <span class="list-group-item-value"> Organization </span> 
             </a>
             <div id='organization-secondary' class="nav-pf-secondary-nav">
               <div class="nav-item-pf-header">
                 <a class="secondary-collapse-toggle-pf", data-toggle="collapse-secondary-nav" ></a>
                 <span>Organization</span>
               </div>
               <ul class="list-group">
                 <li class="list-group-item"><a id="menu_item_Any_Organization"
                     data-id="aid_organizations_clear" href="/organizations/clear">
                  <span class="list-group-item-value">Any Organization</span></a></li>
                 <div class="divider"></div>
                 <li class="list-group-item"><a id="menu_item_org1"
                     data-id="aid_organizations_1_select"
                     href="/organizations/1/select"><span class="list-group-item-value">
                     Org1</span></a></li>
               </ul>
             </div>  
           </li>  
         </ul>     
       </div>
       <div class="container-pf-nav-pf-vertical secondary-visible-pf"></div>`;

  $.fn.setupVerticalNavigation = jest.fn();
  document.body.innerHTML = `<div>
       <li class="dropdown org-switcher" id="location-dropdown">
         <a href="#" class="dropdown-toggle nav-item-iconic" data-toggle="dropdown" >
           Loc1 <span class="caret"></span>
         </a>
       </li>
       <li class="dropdown org-switcher" id="organization-dropdown">
         <a href="#" class="dropdown-toggle nav-item-iconic" data-toggle="dropdown" >
           Org1 <span class="caret"></span>
         </a>
       </li>         
       ${menuWithoutTaxonomies}
     </div>`;
  it('Mark current location/organization as active in vertical menu', () => {
    init();
    expect(
      $('.nav-pf-secondary-nav .list-group-item:contains("Loc1")').hasClass(
        'active'
      )
    ).toBe(true);
    expect(
      $('.nav-pf-secondary-nav .list-group-item:contains("Org1")').hasClass(
        'active'
      )
    ).toBe(true);
  });

  it('Mark main menu item as active', () => {
    expect($('.secondary-nav-item-pf').hasClass('active')).toBe(true);
  });

  it('Should close secondary menu after menu item click', () => {
    $('#menu_item_loc1').click();
    expect($('#vertical-nav').hasClass('hover-secondary-nav-pf')).toBe(false);
    expect(
      $('.container-pf-nav-pf-vertical').hasClass('secondary-visible-pf')
    ).toBe(false);
  });

  it('Should not set secondary menu as active when taxonomies are off', () => {
    document.body.innerHTML = menuWithoutTaxonomies;
    init();
    expect(
      $('.nav-pf-secondary-nav .list-group-item:contains("Loc1")').hasClass(
        'active'
      )
    ).toBe(false);
    expect(
      $('.nav-pf-secondary-nav .list-group-item:contains("Org1")').hasClass(
        'active'
      )
    ).toBe(false);
  });
});
