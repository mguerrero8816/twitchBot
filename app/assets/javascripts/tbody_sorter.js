$(document).ready(function(){
  $(".sorter > th").click(function(){
    var dataSortable = $(this).closest('.sorter').data('sortable')
    var sortable = $('.sortable[data-sorter="' + dataSortable + '"]')
    var sortableRows = sortable.find('tr')
    var clickedColIndex = $(this).index()
    sortByDescending = tagSortOrder($(this))
    if(sortByDescending){
      sortDescending(sortableRows, clickedColIndex).appendTo(sortable)
    } else {
      sortAscending(sortableRows, clickedColIndex).appendTo(sortable)
    }

  })
})

function tagSortOrder(clickedCol){
  var storedSortOrder = clickedCol.data('sort-order')
  clickedCol.closest('tr').find('th').data('sort-order', null)
  clickedCol.closest('tr').find('.sort-indicator').remove()
  var sortByDescending = true
  if(storedSortOrder === 'ascending'){
    clickedCol.data('sort-order', 'descending')
    clickedCol.append('<i class="fa fa-sort-desc sort-indicator" aria-hidden="true"></i>')
  } else if(storedSortOrder === 'descending') {
    sortByDescending = false
    clickedCol.data('sort-order', 'ascending')
    clickedCol.append('<i class="fa fa-sort-asc sort-indicator" aria-hidden="true"></i>')
  } else {
    clickedCol.data('sort-order', 'descending')
    clickedCol.append('<i class="fa fa-sort-desc sort-indicator" aria-hidden="true"></i>')
  }
  return sortByDescending
}

function sortDescending(sortableRows, clickedColIndex){
  return sortableRows.sort(function(a,b){
    tda = $(a).find("td:eq(" + clickedColIndex + ")").text()
    tdb = $(b).find("td:eq(" + clickedColIndex + ")").text()
    if(tda > tdb){
      return 1
    } else if(tda < tdb) {
      return -1
    } else {
      return 0
    }
  })
}

function sortAscending(sortableRows, clickedColIndex){
  return sortableRows.sort(function(a,b){
    tda = $(a).find("td:eq(" + clickedColIndex + ")").text()
    tdb = $(b).find("td:eq(" + clickedColIndex + ")").text()
    if(tda < tdb){
      return 1
    } else if(tda > tdb) {
      return -1
    } else {
      return 0
    }
  })
}
