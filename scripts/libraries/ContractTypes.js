const EventState = {
    Active: 0,
    PaidFor: 1,
    Completed: 2,
    Cancelled: 3
}

const EventAction = {
    Build: 0,
    Demolish: 1,
    Yield: 2
}

const AssetType = {
    None: 0,
    Farm: 1,
    Sawmill: 2,
    Blacksmith: 3,
    Quarry: 4,
    Barrack: 5,
    Stable: 6,
    Market: 7,
    Temple: 8,
    University: 9,
    Wall: 10,
    Watchtower: 11,
    Castle: 12,
    Fortress: 13,
    Population: 14
}


module.exports = {
    EventState,
    EventAction,
    AssetType
};