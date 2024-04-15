function params_format(page, per_page, mag_type=[]) {
  let params = {}
  if (mag_type.length != 0) {
    params = {
      page: page,
      per_page: per_page,
      mag_type:mag_type
    }
  }else {
    params = {
      page: page,
      per_page: per_page
    }
  }
  return params;
};