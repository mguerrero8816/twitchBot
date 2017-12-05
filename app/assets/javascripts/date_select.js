const MONTH_NAMES = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]

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

function datePickerFromMDY(string){
  var year  = "20" + string.slice(6,8)
  var month = parseInt(string.slice(0,2))-1
  var day   = string.slice(3,5)
  return MONTH_NAMES[month] + " " + day + ", " + year
}
