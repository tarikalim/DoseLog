package shared

type MealRelation string

const (
	MealBefore    MealRelation = "before_meal"
	MealAfter     MealRelation = "after_meal"
	MealWith      MealRelation = "with_meal"
	MealIrregular MealRelation = "irrelevant"
)

type TimeSlot string

const (
	Morning TimeSlot = "morning"
	Noon    TimeSlot = "noon"
	Evening TimeSlot = "evening"
	Night   TimeSlot = "night"
)
