# unites wheel/touch events
# cb(down) - down=true when user scrolls down
onvscroll = (cb) ->
  mozilla = $.browser.mozilla
  touch = window.ontouchstart isnt undefined
  eventName = if mozilla then 'wheel' else 'mousewheel'
  $(window).on eventName, (event) ->
    original = event.originalEvent
    delta = original.wheelDeltaY ? original.deltaY ? original.wheelDelta
    delta = -delta if mozilla
    cb(delta < 0)

  if touch
    lastPoint = null
    $(window).on 'touchstart', (event) ->
      # See first touch only, ignore other
      lastPoint = event.originalEvent.touches[0].pageY

    $(window).on 'touchmove', (event) ->
      return if not lastPoint
      delta = event.originalEvent.touches[0].pageY - lastPoint
      cb(delta < 0)

    $(window).on 'touchend', ->
      lastPoint = null


