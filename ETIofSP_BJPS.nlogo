globals [Time] ; 'time': permits defining a timescale at which collectives (a set of cells that do not directly interact with one another) have a chance to produce a propagule.

patches-own [age] ; patches have the properties of collectives: 'age'. When a collective is too old, the cells on it die.

turtles-own [stickiness genotype] ;  cells have two properties: a 'genotype' (that perfectly determines a growth rate) and 'stickiness'.
                                   ; 'stickiness' is a pleiotropic phenotype of the genotype. Its value is *perfectly* anticorrelated with the growth rate. Stickiness also confers to collectives a capacity to resist invasion from cells.
                                   ; 'stickiness' and 'genotype' are also correlated and anticorrelated, respectively, with the capacity to produce a propagule (founder of a new collective).

to setup                                       ; sets of rules defined when the button 'setup' in the UI is pressed.
  ca                                           ; clear all.
  set Time 0
 ; set scaffold? "reverted"                   ; uncomment to test with the default position being the 'reverted' regime.
  ask patches [
    set age random (age-max + 1)              ; sets a random age to patches between 0 and 'age max'.
    set pcolor green                          ; sets the colour of patches as 'green'.
    sprout 1                                  ; each patch produces a cell.
    [ set genotype random-normal 1 0.25       ; sets a genotype of the cell that is taken from a random distribution with a mean of 1 and a standard deviation of 0.3.
      set stickiness (2 - genotype)           ; sets a level of 'stickiness'.
      set color ((genotype / 2) * 9.99  + 10) ; sets a colour that depends on the genotype over a red scale. The higher the growth rate or the lower the stickiness, the lighter the shade.
      set shape "circle"                      ; sets the shape of cells.
      set size 0.5                            ; sets the size of cells.
     ]]
  reset-ticks
end
to go                                                     ; sets of rules defined when the buttons 'go' or 'go forever' in the UI are pressed.
  set Time (Time + 1)                                     ; counts + 1 for the timescale at which the collective can reproduce.
  cell-reproduction                                       ; a cell has a chance to reproduce.
  coll-selection                                          ; a collective dies if it is too large.
  coll-reproduction                                       ; a collective (cells as part of collectives) has a chance to reproduce.
  check-age                                               ; a collective dies if it is too old.
  if Time = timescale? [set Time 0]                       ; creates a long timsecale that corresponds to 'timescale?'. This timescale is composed of 'timescale? - 1' cell generations and one generation at which collectives can reproduce.
  if count turtles = 0
  [stop]                                                  ; the run stops if all cells are dead.

  tick
  if scaffold? = "reverted"                               ; defines a time at which the scaffold is lifted in the 'reverted' condition.
  [if ticks = 1500
    [set scaffold? "no"]]
end
to cell-reproduction                                      ; defines the set of rules for the reproduction of cells.
 if timescale? != Time                                    ; cell do not reproduce when collectives do.
 [ask turtles [
    let dice random-float 2
    if genotype >= dice                                   ; the probability to reproduce depends on a random event 'dice'.
    [hatch 1 [                                            ; if the cell reproduces, it produces one daughter cell.
      rep-mutate                                          ; the daughter cell can be slightly different from its parent (due to some mutation).
      if scaffold? = "no"                                 ; under the 'no scaffold' condition, daughter cells have a chance to move to another patch.
      [if stickiness < random-float 2                     ; the probability to move depends on the level of stickiness of the cell.
        [ let p one-of neighbors                          ; chooses one neighbour patch (p) among the eight neighbours of the patch on which the daughter cell is.
          let dice2 random-float 2                        ; draws a random number between 0 and 2.
          ifelse count turtles-on p = 0                   ; if p has no cell on it, the dauther cell moves to it.
          [move-to p]
          [ifelse dice2 > mean [stickiness] of turtles-on p ; if p contains cells, whether the daughter cell can move to p depends on the mean level of stickiness on p. If stickiness is high (mark of a collective), the probability to move is low.
              [ move-to p]
               []
  ]]]]]]]
end

to coll-selection                                          ; if the number of cells on a patch is too high, the cells die.
  ask patches [
    if count turtles-here > max-coll-size
    [ask turtles-here [die]]]
end
to coll-reproduction                                       ; defines the set of rules for collective reproduction.
if  timescale? = Time                                      ; collectives have an opportunity to reproduce over the timescale T.
  [ask patches
    [if count turtles-here >= 2 and count turtles-here with [stickiness >= 1.5] >= 1   ; collectives can only reproduce if they are composed of at least two cells and if they have a high level of stickiness (above 1.5).
      [ask one-of turtles-here with [stickiness >= 1.5]
          [let p one-of neighbors                        ; chooses one neighbour patch (p) among the eight neighbours.
          let dice random-float 2                        ; draws a random number between 0 and 2.
          ifelse count turtles-on p = 0                  ; if p has no cell on it, a cell on the patch with a high stickiness (above 1.5) becomes a propagule and moves to p.
          [move-to p]
          [ifelse dice > mean [stickiness] of turtles-on p ; if p contains cells, whether the propagule can move to p depends on the mean level of stickiness on p. If stickiness is high (mark of a collective), the probability to move is low.
              [ move-to p
               hatch  1 [rep-mutate]]                      ; once established on a new patch, the propagule produces a daughter cell that can also mutate.
               []
  ]]]]]
end
to rep-mutate                                              ; cell reproduction is not perfect: a daughter cell can be slightly different from its parent.
  set genotype  genotype + 0.02 * ((random-float 1) - 0.5) ; the maximum genotypic difference between parent and offspring is 1% of the maximal genotypic value (2).                                   ;
  if genotype >= 2 [                                       ; if the new genotype is above 2 or below 0, its sets it at 2 and 0, respectively.
        set genotype 2
  ]
  if genotype <= 0 [
        set genotype 0
  ]
  set stickiness (2 - genotype)                            ; the mutation also affects 'stickiness'.
  set color ((genotype / 2) * 9.99 + 10)                   ; the mutation also affects the colour of the cell.
  set shape "circle"
  set size 0.5
 end
to check-age                                               ; a collective can die if it reaches a given age.
  ask patches [
    set age (age + 1)                                      ; sets the new age of patches at each cell generation.
    if age >= age-max
      [ask turtles-here [die]]                             ; when a collective reaches the maximum age ('age-max'), its cells die.
    if any? turtles-here = False                           ; if a collective has no cells on it, its age is reset to 0.
    [set age 0]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
444
8
702
517
-1
-1
25.0
1
10
1
1
1
0
1
1
1
0
9
0
19
0
0
1
ticks
30.0

BUTTON
0
10
64
44
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
44
64
78
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
84
12
173
57
count cells
count turtles
17
1
11

MONITOR
84
55
189
100
count collectives
count patches with [any? turtles-here]
17
1
11

SLIDER
220
84
393
117
age-max
age-max
0
100
30.0
1
1
NIL
HORIZONTAL

PLOT
220
252
421
402
Mean Growth rate
time
mean growth rate
0.0
10.0
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [genotype] of turtles"

SLIDER
216
154
389
187
timescale?
timescale?
3
20
5.0
1
1
NIL
HORIZONTAL

BUTTON
0
79
64
113
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
0
183
129
217
add mutant HG LI
ask n-of 2 turtles [ set genotype 2\n      set color ((genotype / timescale?) * 10  + 10)\n      set shape \"circle\"\n      set size 0.5\n  ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
216
187
389
220
max-coll-size
max-coll-size
4
20
7.0
1
1
NIL
HORIZONTAL

CHOOSER
220
12
376
57
scaffold?
scaffold?
"no" "yes" "reverted"
0

@#$#@#$#@
## WHAT IS IT?
This is an evolutionary biology model of the early phases of an evolutionary transition in individuality. The model has two types of agents: patches and cells. Cells on a patch can form a collective. The model enables the study of how Darwinian properties are acquired at the collective level from processes that can be described purely from the particle level and interaction with the environment at that level.

The model provides a proof-of-principle demonstration of the 'endogenization' of Darwinian properties proposed in Black et al. (2020). The results of this model are discussed in Bourrat (2025).

Cells have three phenotypes, which are all pleiotropic effects of a single genotype:
1) an intrinsic growth rate (perfectly correlated with the genotype) that determines the probability that a cell will reproduce over a cell generation.
2) A dispersion rate from one patch to another after cell reproduction ('stickiness'). A patch containing sticky cells is assumed to be more difficult to invade than a patch containing less sticky cells.
3) A phenotype that measures the capacity of a cell to produce a 'propagule' over a longer timescale (assuming there is a free patch in the neighbourhood).

Importantly, stickiness and the capacity to produce a successful propagule are *negatively* correlated with growth rate. This means that if the growth rate is high, the other two traits are low.

Patches contain resources. At any point in time, patches can contain a maximum number of cells. If more cells are present on a patch, they die of starvation. Resources can also expire. If a patch has had some resources for a time longer than the one set in the model, its resources become unusable and any cells on it die.

The environment beyond the patch level can be in one of two states, depending on the condition of the model.

Condition 1 ('no scaffold' regime): The environment is nearly unstructured, in which case, at every cell generation, a cell has the opportunity to reproduce and its offspring to migrate to a new patch. At regular time intervals that correspond to multiple cell generations (and define a longer timescale), the cells have the opportunity to produce a propagule and send it to a neighbour patch if it is free (i.e., with no cell on it or occupied by non-sticky cells). If there is no free patch, any propagule produced remains on the patch.
To produce a propagule, a collective must be composed of at least two cells.

Condition 2 ('scaffold' regime): The environment is highly structured. As in Condition 1, the cells can reproduce, but offspring cells cannot move to neighbour patches after reproducing *except* if a propagule is produced and a neighbour patch is free (i.e., with no cell on it or occupied by non-sticky cells).

A third 'reverted' regime is also proposed in the model. It represents a mix of the two others (scaffold for the first 1500 generations and no-scaffold for the rest of the run).

## DYNAMICS

If we run the model under the no-scaffold regime, starting with a population of cells with an average growth rate of 1 (values drawn from a normal distribution with a mean of 1 and standard deviation of 0.25), the population evolves towards a high mean growth rate (nearly maximum).

If the same population is evolved under the scaffold regime, most of the cells produced are propagules, and the intrinsic growth rate remains at a low level. This corresponds to a situation where the collective-level properties are scaffolded, which is consistent with some of the results found in Black et al. (2020).

When the model is run under the reverted regime, the dynamics become more interesting. Under some conditions within that regime, we obtain a situation where the average cell growth rate remains low even after the scaffold has been lifted (from cell generation 1500 onward). Reproduction occurs primarily via the production of propagules over a long timescale rather than by cell reproduction over a short timescale.

The dynamics observed under the reverted regime demonstrate 1) the potential emergence of collective-level entities from the existence of a scaffold at the cell level and 2) the possibility for the collective level to endogenize this scaffold.

## HOW IT WORKS

The model has three stages in each cell generation.

1. *a. Cell reproduction*: The cells can reproduce (and the cell produced can either move to another patch or not if there is a scaffold). During reproduction, some mutation can occur. This stage occurs at every cell generation that is not a multiple of the longer timescale.  
   *b. Collective reproduction*: Collectives (via a cell) with at least two cells have the opportunity to produce a propagule over the long timescale.

2. *Collective selection*: Collectives that are too large are eliminated at every time step.

3. *Collective elimination*: Collectives over 30 cell generations (in the default parameter set) old are destroyed; any cell contained is killed. These collectives are then replenished with resources and become suitable for cell life (assessed at each time step).

This cycle is repeated indefinitely unless the number of cells in the population is 0.

## HOW TO USE IT

'setup' button — sets up the model by creating the agents.

'go' button — runs the model.

'scaffold?' chooser — lets you determine the regime: no-scaffold, scaffold or reverted.

'age-max' slider — lets you determine the maximum age of a collective before it is eliminated and then replenished with resources.

'timescale?' slider — lets you determine the timescale at which collectives are allowed to produce a propagule.

'max-coll-size' slider — lets you determine the maximum size a collective can reach before resource over-exploitation occurs.

## CREDITS AND REFERENCES

Black, Andrew J., Pierrick Bourrat, and Paul B. Rainey (2020). “Ecological Scaffolding and the Evolution of Individuality.” *Nature Ecology & Evolution* 4: 426–36. https://doi.org/10.1038/s41559-019-1086-9.

Bourrat, Pierrick (2025). "Evolutionary Transitions in Individuality by Endogenization of Scaffolded Properties". *British Journal for the Philosophy of Science*, 76, <https://doi.org/10.1086/719118>. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Eco Scaffolding 2.0 Yes and reverted" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="40000"/>
    <metric>mean [genotype] of turtles</metric>
    <enumeratedValueSet variable="scaffold?">
      <value value="&quot;reverted&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="timescale?" first="3" step="1" last="10"/>
    <steppedValueSet variable="max-coll-size" first="4" step="2" last="20"/>
    <enumeratedValueSet variable="age-max">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
