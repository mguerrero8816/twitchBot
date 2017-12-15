function bindJsFormSubmitters(){
  $(".js-submit-form").click(function(){
    var form = $(this).closest(".js-form-container").find("form")
    var formFields = {}
    $(this).closest(".js-form-fields-container").find(":input").each(function(){
      var fieldValue = $(this).val()
      var fieldName = $(this).attr("name")
      form.append('<input name="' + fieldName + '" type="hidden" value="' + fieldValue + '">')
    })
    form.submit()
  })
}
