package com.burnout.app.domain.model

// Not a Hive @HiveType in the Dart source, so not a Room-persisted enum
// either — used only in-memory by the battle-report flow.
enum class WeightMode { WEIGHTED, BODYWEIGHT, ASSISTED }
