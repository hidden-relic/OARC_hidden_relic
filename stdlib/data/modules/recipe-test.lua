-- luacheck: ignore Data test Recipe RecipeOld recipe recipeOld
local Data = require('stdlib/data/data')
local RecipeOld = require('stdlib/data/recipe')
local Recipe = require('stdlib/data/modules/recipe')


local recipeOld = RecipeOld('stone-furnace')
local recipe = Recipe('stone-furnace')

print(recipe:Ingredients():log())

--recipe:log()
--recipe:Ingredients()():Results()():log()
