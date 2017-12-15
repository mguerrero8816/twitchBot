function bindExpanders(){
  $('.expander').click(function(){
    var expandableTargeter = $(this).data('expander')
    $('[data-expandable="' + expandableTargeter + '"]').toggle()
  })
}
