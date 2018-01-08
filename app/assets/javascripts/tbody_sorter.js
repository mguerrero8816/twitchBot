$(document).ready(function(){
  $(".sorter > th").click(function(){
    var dataSortable = $(this).closest('.sorter').data('sortable')
    var sortable = $('.sortable[data-sorter="' + dataSortable + '"]')
    var sortableRows = sortable.find('tr')
    var clickedCol = $(this).index()
    
    sortableRows.sort(function(a,b){
      tda = $(a).find("td:eq(" + clickedCol + ")").text()
      tdb = $(b).find("td:eq(" + clickedCol + ")").text()
      if(tda < tdb){
        return 1
      } else if(tda > tdb) {
        return -1
      } else {
        return 0
      }
    }).appendTo(sortable)
  })
})
