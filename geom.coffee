# numbersBetween 0, 4, 1 --> [2]
# numbersBetween 0, 4, 3 --> [1,2,3]
numbersBetween = (a1, a2, amount) ->
  distance = Math.abs(a2 - a1)
  direction = if a2 > a1 then 1 else -1
  step = direction * distance / (amount + 1)
  numbers = []
  cursor = a1
  while amount--> 0
    cursor += step
    numbers.push cursor
  numbers

# numbersBetween 0, 4, 3 --> [0,2,4]
numbersBetweenInclusive = (a1, a2, amount) ->
  [a1].concat(numbersBetween(a1, a2, amount-2)).concat [a2]

pointsBetween = (p1, p2, amount) ->
  xs = numbersBetween p1[0], p2[0], amount
  ys = numbersBetween p1[1], p2[1], amount
  xs.map (x, index) -> [x, ys[index]]

pointsBetweenInclusive = (p1, p2, amount) ->
  [p1].concat(pointsBetween(p1, p2, amount-2)).concat [p2]

transitionBetween = (figure1, figure2, amount) ->
  throw "Figures shall have identical amount of points" if figure1.length != figure2.length
  transitionsPerPoints = figure1.map (point, index) ->
    pointsBetweenInclusive point, figure2[index], amount
  figuresPerStep = [0...amount].map (step) -> transitionsPerPoints.map (pointSteps) -> pointSteps[step]
  figuresPerStep

generatePolyline = (corners, amounts) ->
  points = []
  for point, index in corners.slice(0, corners.length - 1)
    points.push point
    points = points.concat pointsBetween point, corners[index+1], amounts[index]
  points

# w,h - relative sizes (-1..1)
# amountInQuarter - amount of points in each quarter. If 0 then only 4 corner points will be generated
generateRhombusPoints = (w, h, amountInQuarter) ->
  TOP =     [0,  -h]
  RIGHT =   [w,  0]
  BOTTOM =  [0,  h]
  LEFT =    [-w, 0]
  generatePolyline [TOP, RIGHT, BOTTOM, LEFT, TOP], [amountInQuarter, amountInQuarter, amountInQuarter, amountInQuarter]

angleToPoint = (r, angle) -> [Math.cos(angle) * r, Math.sin(angle) * r]

# r - relative size (-1..1)
# amountInQuarter - amount of points in each quarter. If 0 then only 4 corner points will be generated
generateCirclePoints = (r, amountInQuarter) ->
  TOP =     - Math.PI / 2
  RIGHT =   0
  BOTTOM =  Math.PI / 2
  LEFT =    Math.PI
  points = []
  angles = [TOP, RIGHT, BOTTOM, LEFT, TOP + 2*Math.PI]
  for angle, index in angles.slice(0, 4)
    points.push angleToPoint(r, angle)
    points = points.concat (numbersBetween angle, angles[index+1], amountInQuarter).map (angle) -> angleToPoint(r, angle)
  points

# here will be equal-edges triangle "included" into circle with radius r
# in summary there will be 4*(amountInQuarter+1) points as for other figures, actally
# 'quarter' has no meaning for triangle
generateTrianglePoints = (r, amountInQuarter) ->
  TOP = angleToPoint(r, -Math.PI / 2)
  RIGHT_BOTTOM = angleToPoint(r, -Math.PI/2 + Math.PI*2/3)
  LEFT_BOTTOM = angleToPoint(r, -Math.PI/2 - Math.PI*2/3)
  totalPointsButCorner = (amountInQuarter+1)*4 - 3
  amountOnEdge = Math.ceil(totalPointsButCorner/3)
  amountOnLastEdge = (totalPointsButCorner - amountOnEdge*2)
  generatePolyline [TOP, RIGHT_BOTTOM, LEFT_BOTTOM, TOP], [amountOnEdge, amountOnEdge, amountOnLastEdge]


