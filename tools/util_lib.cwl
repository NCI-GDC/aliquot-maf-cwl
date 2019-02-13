- |
  function sum_file_array_size(farr) {
    var divisor = 1048576;
    var total = 0;
    for (var i = 0; i<farr.length; i++) {
      if(farr[i] != null) {
        total += farr[i].size
      }
    } 
    return Math.ceil(total / divisor);
  }

- |
  function size_from_input_object(inputs) {
    var divisor = 1048576;
    var total = 0;
    for (var k in inputs) {
      var curr = inputs[k];
      if (curr != null) {
        if ( Array.isArray(curr) ) {
          for (var i = 0; i<curr.length; i++) {
            if(curr[i].hasOwnProperty("class") && curr[i].class == "File") {
              total += curr[i]["size"];
            }
          }
        }

        else {
          if(curr.hasOwnProperty("class") && curr.class == "File") {
            total += curr["size"];
          }
        }
      }
    }

    return Math.ceil(total / divisor);
  }

- |
  function lookup_optional_file(opt_obj, key) {
    var res = [];

    for (var i=0; i<opt_obj.length; i++) {
      var curr = opt_obj[i];
      if(curr.key == key) {
        res.push(curr.file);
      }
    }

    return res; 
  }
