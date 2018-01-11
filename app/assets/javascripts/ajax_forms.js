$(document).ready(function(){
  bindPostFormWithAjax()
  bindGetFormWithAjax()
})

function bindGetFormWithAjax(element){
  var getForms
  var targetClass = "form.get-with-ajax"
  if(element === undefined){
    getForms = $(targetClass)
  } else {
    getForms = $(element + " " + targetClass)
  }
  getForms.submit(function(){
    $.get(this.action, $(this).serialize(), null, "script")
    return false
  })
}

function bindPostFormWithAjax(element){
  var postForms
  var targetClass = "form.post-with-ajax"
  if(element === undefined){
    postForms = $(targetClass)
  } else {
    postForms = $(element + " " + targetClass)
  }
  postForms.submit(function(){
    $.post(this.action, $(this).serialize(), null, "script")
    return false
  })
}
