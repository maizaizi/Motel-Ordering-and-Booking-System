(function(){
	var widget, initAF = function() {
      widget = new AddressFinder.Widget(
          $("#address")[0],
          "6CRHDK9AE4YPMQU3V7X8",
          'NZ'
      );
     widget.on("result:select", function(fullAddress, metaData) {
       var selected = new AddressFinder.NZSelectedAddress(fullAddress, metaData);
      $('#address')[0].value = selected.address_line_1()+', '+selected.address_line_2()+' '+selected.suburb()+', ' +selected.city()+ ' '+selected.postcode();
    });
  };
  $( document ).ready(function() {
		$.getScript('https://api.addressfinder.io/assets/v3/widget.js', initAF);
    $('#card_number').on('input', function() {
      let val = $(this).val().replace(/\s/g, '');
      let newVal = '';
      for (let i = 0; i < val.length; i++) {
          if (i % 4 === 0 && i > 0) {
              newVal += ' ';
          }
          newVal += val[i];
      }
      $(this).val(newVal);
  });
	});

})();