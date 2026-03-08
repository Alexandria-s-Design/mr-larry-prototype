extends Node
## Curriculum Data — The 13 financial literacy topics as life events.
## Each event triggers naturally during gameplay at the right time.

# Curriculum events: triggered by week number and conditions
var events: Array[Dictionary] = [
	{
		"id": "curriculum_01",
		"title": "Welcome to Your New Life!",
		"phase": "LIFE",
		"trigger_week": 1,
		"trigger_period": "morning",
		"description": "It's your first day! You've got a room, some spending money, and big dreams. But first — let's figure out where you stand.",
		"mr_larry_intro": "Hey there! I'm Mr. Larry, your neighbor. Welcome to the neighborhood! Let me share something important — your financial life is like an iceberg. What people see on the surface? That's just the tip. The REAL wealth is what's underneath.",
		"options": [
			{"label": "Set a savings goal right away", "score": 20, "budget_cost": 0,
			 "consequence": "Smart thinking! Having a goal gives your money purpose.",
			 "mr_larry_says": "I love it! A goal is like a compass — it tells your money where to go instead of wondering where it went.",
			 "energy_impact": 5, "fun_impact": 5},
			{"label": "Check out what's in the store first", "score": 10, "budget_cost": 0,
			 "consequence": "Good to know what's out there! Just remember — looking isn't the same as buying.",
			 "mr_larry_says": "Window shopping is smart! Know what things cost before you decide what to save for."},
			{"label": "Spend a little to make the room feel like home", "score": 5, "budget_cost": 3,
			 "consequence": "Your room looks a bit nicer! But you spent $3 already...",
			 "mr_larry_says": "Nothing wrong with making your space comfortable. Just make sure you're not spending everything on day one!"},
		]
	},
	{
		"id": "curriculum_02",
		"title": "Allowance Day!",
		"phase": "LIFE",
		"trigger_week": 2,
		"trigger_period": "morning",
		"description": "It's payday! You earned $10 this week from chores. Now comes the big question — what do you do with it?",
		"mr_larry_intro": "Payday! This is where the magic happens. Ever heard of Save, Spend, Share? It's the smartest way to handle money.",
		"options": [
			{"label": "Split it: Save $4, Spend $4, Share $2", "score": 25, "budget_cost": -10,
			 "consequence": "Balanced approach! You've got spending money AND savings growing.",
			 "mr_larry_says": "The 40/40/20 split! That's what I call financial wisdom. Your save jar will grow faster than you think.",
			 "badge": "First Allocator"},
			{"label": "Save most of it: Save $7, Spend $2, Share $1", "score": 20, "budget_cost": -10,
			 "consequence": "Big saver! Your savings will grow fast, but not much fun money this week.",
			 "mr_larry_says": "You're thinking long-term! Just make sure you leave a little for fun — balance matters."},
			{"label": "Keep it all for spending", "score": 5, "budget_cost": -10,
			 "consequence": "All spending money! Fun now, but nothing saved for later.",
			 "mr_larry_says": "I get it — money burns a hole in your pocket sometimes. But try to save even a little next time. Future you will thank present you."},
		]
	},
	{
		"id": "curriculum_03",
		"title": "Mom's Grocery Run",
		"phase": "LIFE",
		"trigger_week": 3,
		"trigger_period": "afternoon",
		"description": "Mom sends you to the grocery store with a list and $40. You need green beans, chicken, bread, a drink, and milk. Every item has 3 versions at different prices — and the cheapest isn't always the best deal.",
		"mr_larry_intro": "Grocery shopping is one of the most important financial skills you'll ever learn. Every family does it, and the choices add up over a LIFETIME. Let's see how you handle it!",
		"options": [
			{"label": "Buy fresh and healthy ($18.50 total)", "score": 25, "budget_cost": 18.5,
			 "consequence": "Best nutrition for the family! Spent more but the health benefits are worth it. You have $21.50 left.",
			 "mr_larry_says": "Fresh green beans, whole chicken, wheat bread, water, and non-fat milk — that's a healthy family right there! And you stayed well under budget!",
			 "hunger_impact": 30, "energy_impact": 10,
			 "badge": "Smart Shopper"},
			{"label": "Mix of fresh and frozen ($14.50 total)", "score": 20, "budget_cost": 14.5,
			 "consequence": "Good balance of price and nutrition. You saved money AND ate well. $25.50 left!",
			 "mr_larry_says": "Frozen veggies are actually picked at peak freshness — great nutrition for less money. Smart mixing!",
			 "hunger_impact": 25, "energy_impact": 5},
			{"label": "Go cheap on everything ($9.00 total)", "score": 10, "budget_cost": 9.0,
			 "consequence": "Saved a lot of money! But canned goods, white bread, and soda aren't great for the family's health.",
			 "mr_larry_says": "You saved money, which is good! But check those labels — high sodium, low nutrition. Sometimes the cheapest option costs more in the long run through health impacts.",
			 "hunger_impact": 15, "energy_impact": -5},
		]
	},
	{
		"id": "curriculum_04",
		"title": "Your First Paycheck",
		"phase": "LIFE",
		"trigger_week": 5,
		"trigger_period": "morning",
		"description": "You got a part-time job! Your first paycheck is $50... but wait. After taxes and deductions, you only take home $42.50. Where did $7.50 go?!",
		"mr_larry_intro": "Welcome to the real world! That $7.50 went to taxes — Social Security, Medicare, and income tax. Everyone pays them. The question is: what do you do with what's left?",
		"options": [
			{"label": "Save half, spend the rest wisely", "score": 25, "budget_cost": -42.5,
			 "consequence": "You saved $21.25 and have the rest for spending. Your savings account is growing!",
			 "mr_larry_says": "Now you're thinking like someone who builds wealth! Paying yourself first is the #1 rule of financial success.",
			 "badge": "First Paycheck"},
			{"label": "Treat yourself — you earned it!", "score": 10, "budget_cost": -42.5,
			 "consequence": "You spent most of your paycheck on fun stuff. Felt great today... but your savings didn't grow.",
			 "mr_larry_says": "You worked hard and deserve nice things! But remember — the difference between rich and broke is often just what you do with your paycheck.",
			 "fun_impact": 20},
			{"label": "Save it ALL", "score": 15, "budget_cost": -42.5,
			 "consequence": "Maximum savings! But zero fun money this week. That's tough to sustain.",
			 "mr_larry_says": "I admire the discipline! But even the best savers need a little fun money. All-or-nothing usually doesn't last."},
		]
	},
	{
		"id": "curriculum_05",
		"title": "The Dream Item",
		"phase": "DREAMS",
		"trigger_week": 7,
		"trigger_period": "afternoon",
		"description": "You see the PERFECT item in the store — a Game Console for $60! You don't have enough right now. What's your plan?",
		"mr_larry_intro": "Ooh, I see that look in your eye! That's wanting something big. This is where dreams meet planning. Let's think about this...",
		"options": [
			{"label": "Set a 4-week savings plan ($15/week)", "score": 25, "budget_cost": 0,
			 "consequence": "You made a plan! Save $15 each week for 4 weeks and it's yours. The waiting makes it sweeter.",
			 "mr_larry_says": "A savings PLAN! That's what separates dreamers from achievers. Four weeks of patience = years of gaming. I'm proud of you!",
			 "badge": "Dream Planner"},
			{"label": "Ask parents for an advance on allowance", "score": 10, "budget_cost": 0,
			 "consequence": "Mom says you can borrow $30 but next month's allowance will be reduced. It's like a mini-loan!",
			 "mr_larry_says": "Borrowing is a real financial tool! But notice — you'll pay it back through smaller allowances. That's how interest works in the real world."},
			{"label": "Forget it — buy something smaller now", "score": 5, "budget_cost": 15,
			 "consequence": "You bought a $15 Music Player instead. It's fun but... you still want that console.",
			 "mr_larry_says": "Instant gratification vs. delayed gratification. The music player is nice! But the console would have brought more value. Something to think about.",
			 "fun_impact": 10},
		]
	},
]


func get_available_event(week: int, period: String, completed: Array) -> Dictionary:
	for event in events:
		if event.id in completed:
			continue
		if week >= event.trigger_week and period == event.trigger_period:
			return event
	return {}


func get_event_by_id(event_id: String) -> Dictionary:
	for event in events:
		if event.id == event_id:
			return event
	return {}
