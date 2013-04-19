$(document).on 'click', '.js-lineprof-file', (e) ->
  $(this).parents('.peek-rblineprof-file').next('div').toggle()
  alert 'wtf'
  e.preventDefault()
  false

$ ->
