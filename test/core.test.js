import test from 'node:test';
import assert from 'node:assert/strict';
import { consolidate, formatQuantity, scaleIngredient } from '../public/core.js';
test('scales ingredients by planned servings',()=>assert.equal(scaleIngredient({quantity:2},6,2).quantity,6));
test('consolidates the same ingredient across recipes',()=>{const recipes=[{id:'a',title:'A',servings:2,ingredients:[{name:'Lemon',quantity:1,unit:'whole',aisle:'Produce'}]},{id:'b',title:'B',servings:1,ingredients:[{name:'Lemon',quantity:2,unit:'whole',aisle:'Produce'}]}];const result=consolidate([{recipeId:'a',servings:4},{recipeId:'b',servings:1}],recipes);assert.equal(result.length,1);assert.equal(result[0].quantity,4);assert.deepEqual(result[0].recipes,['A','B'])});
test('formats common shopping fractions',()=>{assert.equal(formatQuantity(.5),'0½');assert.equal(formatQuantity(2),'2')});
