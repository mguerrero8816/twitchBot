$(document).ready(function(){
  bindDatepicker()
})

function bindDatepicker(element){
  var datepickers
  if(element === undefined){
    datepickers = $(".jsDatepicker")
  } else {
    datepickers = $(element + " .jsDatepicker")
  }
  var railsDate
  var datepickerDate
  datepickers.each(function(){
    railsDate = $(this).val()
    if(railsDate.includes("/")){
      datepickerDate = datePickerFromMDY(railsDate)
      $(this).val(datepickerDate)
    }
  })
  datepickers.datepicker({ dateFormat: "MM dd, yy", changeMonth: true, changeYear: true, yearRange: "2004:+10" }).val()
}
