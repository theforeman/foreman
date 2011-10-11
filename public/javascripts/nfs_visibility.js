function nfs_section_visibility(os_has_nfs){
  $('.inputs-list :checkbox').each(function (i) {
    $(this).change(os_has_nfs, toggle_nfs_section)
  })
  $("input:submit").each(function (i) {
    $(this).change(os_has_nfs, check_nfs_section)
  })
}
function count_checked_nfs(os_has_nfs){
  var count = 0;
  $('.inputs-list :checkbox').each(function(i) {
    if(os_has_nfs[i] == true && this.checked) {
      count ++;
    }
  })
  return count
}
function toggle_nfs_section(event){
  var os_has_nfs = event.data;
  if (count_checked_nfs(os_has_nfs) >=1) {
    $('#nfs-section').show();
  } else {
    $('#nfs-section').hide();
  }
}
function check_nfs_section(event){
  var os_has_nfs = event.data;
  if (count_checked_nfs(os_has_nfs) == 0) {
    $('#medium_media_path').attr("value", "")
    $('#medium_config_path').attr("value", "")
    $('#medium_image_path').attr("value", "")
  }
}
