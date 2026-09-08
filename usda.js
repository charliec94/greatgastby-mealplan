function nutrient(food,id,names=[]){const found=(food.foodNutrients||[]).find(n=>Number(n.nutrientId||n.nutrient?.id)===id||names.includes(String(n.nutrientName||n.nutrient?.name||'').toLowerCase()));return Number(found?.value??found?.amount)||0}

export function normalizeUsdaFood(food){return{fdcId:food.fdcId,name:food.description||'Unnamed food',brand:food.brandOwner||food.brandName||'',dataType:food.dataType||'',amount:100,unit:'g',basis:'100 g',calories:Math.round(nutrient(food,1008,['energy'])),protein:Math.round(nutrient(food,1003,['protein'])*10)/10}}
