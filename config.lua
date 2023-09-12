config = {}

config.license = 'hunting'
config.weaponUsedForHunting = 'weapon_sniperrifle'

config.chanceToGetAntlers = 50
config.amounts = {
    Deer = {
        minHide = 3,
        maxHide = 7,
        minMeat = 5,
        maxMeat = 9
    },
    Pig = {
        minHide = 2,
        maxHide = 6,
        minMeat = 9,
        maxMeat = 13
    },
    Mtlion = {
        minHide = 1,
        maxHide = 4,
        minMeat = 4,
        maxMeat = 8
    },
    Boar = {
        minHide = 2,
        maxHide = 6,
        minMeat = 10,
        maxMeat = 14
    },
    Rabbit = {
        minHide = 1,
        maxHide = 2,
        minMeat = 1,
        maxMeat = 2
    }
}
config.prices = {
    Deer = {
        deerhide = {
            minPrice = 100,
            maxPrice = 200
        },
        deermeat = {
            minPrice = 50,
            maxPrice = 150
        },
        deerantlers = {
            minPrice = 300,
            maxPrice = 400
        }
    },
    Pig = {
        pighide = {
            minPrice = 50,
            maxPrice = 100
        },
        pigmeat = {
            minPrice = 100,
            maxPrice = 200
        }
    },
    Mtlion = {
        mtlionhide = {
            minPrice = 200,
            maxPrice = 300
        },
        mtlionmeat = {
            minPrice = 100,
            maxPrice = 200
        }
    },
    Boar = {
        boarhide = {
            minPrice = 75,
            maxPrice = 125
        },
        boarmeat = {
            minPrice = 100,
            maxPrice = 150
        }
    },
    Rabbit = {
        rabbithide = {
            minPrice = 50,
            maxPrice = 100
        },
        rabbitmeat = {
            minPrice = 50,
            maxPrice = 100
        }
    }

}

config.huntingSellables = {
    {itemName = 'deerhide', itemLabel = 'Deer hide', animalType = 'Deer'},
    {itemName = 'deermeat', itemLabel = 'Deer meat', animalType = 'Deer'},
    {itemName = 'deerantlers', itemLabel = 'Deer Antlers', animalType = 'Deer'},
    {itemName = 'pighide', itemLabel = 'Pig leather', animalType = 'Pig'},
    {itemName = 'pigmeat', itemLabel = 'Pig meat', animalType = 'Pig'},
    {itemName = 'boarhide', itemLabel = 'Boar hide', animalType = 'Boar'},
    {itemName = 'boarmeat', itemLabel = 'Boar meat', animalType = 'Boar'},
    {itemName = 'mtlionhide', itemLabel = 'Mountain lion hide', animalType = 'Mtlion'},
    {itemName = 'mtlionmeat', itemLabel = 'Mountain lion meat', animalType = 'Mtlion'},
    {itemName = 'rabbithide', itemLabel = 'Rabbit hide', animalType = 'Rabbit'},
    {itemName = 'rabbitmeat', itemLabel = 'Rabbit meat', animalType = 'Rabbit'},

}

config.blip = {
    location = vector4(-679.3, 5834.31, 17.33, 127.51),
    blipName = 'Hunting'
}
config.hunter = {
    model = 'cs_hunter',
    coords = vector4(-679.25, 5834.31, 16.33, 133.48),
    zoneOptions = { 
        length = 3.0,
        width = 3.0
    }
}


config.carRentPrice = 2000
config.carReturnMoney = 1500

config.groupBonus = {
    [1] = 1.2,
    [2] = 1.4,
    [3] = 1.6,
    [4] = 1.8
}