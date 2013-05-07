$(document).on 'click', '.js-lineprof-file', (e) ->
  $(this).parents('.peek-rblineprof-file').next('div').toggle()
  e.preventDefault()
  false

$ ->
