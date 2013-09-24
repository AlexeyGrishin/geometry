# generates random color as array of [r,g,b]
randomColor = ->
  r = -> (Math.random() * 224)
  [r(), r(), r()]

# converts color array [r,g,b] to style string
colorToString = (color) ->
  "rgb(" + color.map(Math.floor).join(",") +  ")"

# returns colors transition
colorsBetweenInclusive = (colorFrom, colorTo, amount) ->
  colorSteps = [0..2].map (idx) -> numbersBetweenInclusive colorFrom[idx], colorTo[idx], amount
  [0...amount].map (step) -> [0..2].map (idx)-> colorSteps[idx][step]