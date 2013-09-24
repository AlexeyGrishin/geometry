POINTS = 50           # how many points to use for figures. more --> quality
STEPS = 80            # how many steps will be in animation. more --> slower
STEP_ON_SCROLL = 10   # how many steps will be passed on each scroll. more --> smoother
DELAY_ON_SCROLL = 10  # delay between steps

$ ->
  canvas = initCanvas()
  rhombus = generateRhombusPoints(0.3, 0.4, POINTS)
  triangle = generateTrianglePoints(0.4, POINTS)
  circle = generateCirclePoints(0.4, POINTS)

  rhombusToCircle = ->
    transitionBetween rhombus, circle, STEPS
  rhombusToTriangleToCircle = ->
    firstSteps = Math.floor(STEPS / 2)
    secondSteps = STEPS - firstSteps + 1
    (transitionBetween rhombus, triangle, firstSteps).concat(
      (transitionBetween triangle, circle, secondSteps).slice(1)
    )

  transition = rhombusToTriangleToCircle()
  colors = colorsBetweenInclusive randomColor(), randomColor(), STEPS
  movement = numbersBetweenInclusive -0.4, 0.4, STEPS

  drawStep = (step) ->
    clear canvas
    canvas.fillStyle = colorToString colors[step]
    drawFigure canvas, moveFigure transition[step], 0, movement[step]

  onStep = (step) ->
    if step == STEPS - 1
      # change first color
      colors = colorsBetweenInclusive randomColor(), colors[colors.length-1], STEPS
    else if step == 0
      # change last color
      colors = colorsBetweenInclusive colors[0], randomColor(), STEPS

  animation = initAnimation(drawStep, transition.length, onStep)
  $(window).resize ->
    initCanvas()
    animation.draw()

initAnimation = (drawStep, stepsAmount, onStep) ->

  animation =
    currentStep: 0
    currentMotionTo: 0
    targetStep: 0
    animateTo: (@targetStep) ->
      clearTimeout @currentMotionTo
      nextStep = =>
        @move @currentStep < @targetStep
        @draw()
        if @currentStep != @targetStep
          @currentMotionTo = setTimeout nextStep, DELAY_ON_SCROLL
      nextStep()

    move: (forward) ->
      if forward and @currentStep < stepsAmount - 1
        @currentStep++
      if not forward and @currentStep > 0
        @currentStep--
      @draw()
      @_onCurrentStepChange()

    _onCurrentStepChange: ->
      onStep @currentStep

    animate: (forward) ->
      if forward and @currentStep < stepsAmount - 1
        @animateTo Math.min(@currentStep + STEP_ON_SCROLL, stepsAmount - 1)
      if not forward and @currentStep > 0
        @animateTo Math.max(@currentStep - STEP_ON_SCROLL, 0)

    start: ->
      @currentStep = 0
      @draw()

    end: ->
      @currentStep = stepsAmount - 1
      @draw()

    draw: ->
      drawStep @currentStep

  onvscroll (down) ->
    animation.animate down

  animation.start()
  animation


W = null
H = null
CX = null
CY = null
DW = null
DH = null

initialize = (width, height) ->
  W = width
  H = height
  CX = W / 2
  CY = H / 2
  PAD = 5
  DW = W/2 - PAD
  DH = H/2 - PAD

clear = (canvas) ->
  canvas.clearRect(0, 0, W, H)

realX = (p) ->
  (p[0] ? p) * DW + CX

realY = (p) ->
  (p[1] ? p) * DH + CY

drawPoints = (canvas, points) ->
  points.forEach ([x,y]) ->
    canvas.fillRect realX(x)-1, realY(y)-1, 2, 2

moveFigure = (points, offsetX, offsetY) ->
  points.map (p) -> [p[0] + offsetX, p[1] + offsetY]

drawFigure = (canvas, points) ->
  canvas.beginPath()
  canvas.moveTo realX(points[0]), realY(points[0])
  points.slice(1).forEach ([x,y]) ->
    canvas.lineTo realX(x), realY(y)
  canvas.closePath()
  canvas.fill()

initCanvas = ->
  el = $("canvas")
  size = Math.min $(window).width(), $(window).height()
  el.attr "width", size
  el.attr "height", size
  initialize el.width(), el.height()
  $("canvas")[0].getContext("2d")



