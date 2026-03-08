extends Node
## Random Events — Financial surprises that happen during life.
## These teach financial concepts through natural consequences.

var events: Array[Dictionary] = [
	{
		"id": "random_found_money",
		"title": "Lucky Find!",
		"description": "You found $5 on the ground outside! What do you do?",
		"mr_larry_intro": "Free money! But how you handle unexpected money says a lot about your financial habits.",
		"options": [
			{"label": "Put it in savings", "score": 15, "budget_cost": -5,
			 "consequence": "Straight to the save jar! Your future self is smiling.",
			 "mr_larry_says": "Windfall savings! That's the habit of wealthy people — treat unexpected money as bonus savings, not bonus spending."},
			{"label": "Treat yourself to something small", "score": 5, "budget_cost": -5,
			 "consequence": "You bought a snack. Tasty! But the $5 is gone now.",
			 "mr_larry_says": "Nothing wrong with a treat! Just notice how fast $5 disappears when you spend it vs. how it grows when you save it.",
			 "hunger_impact": 15},
			{"label": "Share it — buy a friend a snack", "score": 10, "budget_cost": -5,
			 "consequence": "Your friend was so happy! Generosity builds relationships.",
			 "mr_larry_says": "Sharing is the third jar for a reason! Generosity is good for the community AND for your friendships.",
			 "social_impact": 15},
		]
	},
	{
		"id": "random_phone_cracked",
		"title": "Phone Screen Cracked!",
		"description": "You dropped your phone and the screen cracked! It still works but it's hard to read.",
		"mr_larry_intro": "Uh oh! This is exactly why emergency savings matter. Let's see your options...",
		"options": [
			{"label": "Repair it — $15", "score": 15, "budget_cost": 15,
			 "consequence": "Good as new! A smart, affordable fix.",
			 "mr_larry_says": "Repairing instead of replacing! That saved you $35. Smart money move.",
			 "social_impact": 5},
			{"label": "Buy a new one — $50", "score": 5, "budget_cost": 50,
			 "consequence": "Brand new phone! But your savings took a massive hit...",
			 "mr_larry_says": "Shiny and new is nice, but $50 for a phone when $15 repair was available? That's $35 of lost savings.",
			 "social_impact": 15, "fun_impact": 10},
			{"label": "Live with the crack — $0", "score": 10, "budget_cost": 0,
			 "consequence": "Tough it out! Saves money but a little harder to use.",
			 "mr_larry_says": "Sometimes the best financial decision is to NOT spend money. You can save up for a repair when the time is right.",
			 "social_impact": -5},
		]
	},
	{
		"id": "random_friend_birthday",
		"title": "Friend's Birthday Party!",
		"description": "Your best friend's birthday is this weekend. You need a gift! What's your budget?",
		"mr_larry_intro": "Friendship is priceless, but gifts have prices! Let's find the right balance.",
		"options": [
			{"label": "Make a homemade gift — $2 for supplies", "score": 20, "budget_cost": 2,
			 "consequence": "Your friend LOVED it! The personal touch meant more than anything store-bought.",
			 "mr_larry_says": "Creativity > cost. The most memorable gifts are often the ones money can't buy. And you only spent $2!",
			 "social_impact": 20},
			{"label": "Buy a nice gift — $15", "score": 10, "budget_cost": 15,
			 "consequence": "Great gift! Your friend was happy. But that's a chunk of spending money gone.",
			 "mr_larry_says": "A generous gift! Just make sure gift-giving doesn't break your budget. True friends value the thought, not the price tag.",
			 "social_impact": 15},
			{"label": "Buy an expensive gift — $30", "score": 5, "budget_cost": 30,
			 "consequence": "Wow, big spender! Your friend was thrilled but your wallet is hurting.",
			 "mr_larry_says": "That's very generous! But spending beyond your means — even for friends — can become a problem. Watch that budget!",
			 "social_impact": 20, "fun_impact": -5},
		]
	},
	{
		"id": "random_bogo_sale",
		"title": "HUGE SALE at the Store!",
		"description": "The store has a Buy One Get One Free sale on shoes! Regular price $20 each. Do you need shoes? Not really...",
		"mr_larry_intro": "Sales! The store's favorite trick. A 'deal' is only a deal if you needed it in the first place...",
		"options": [
			{"label": "Skip it — I don't need shoes", "score": 25, "budget_cost": 0,
			 "consequence": "You walked away! That took discipline. Your money stays in your pocket.",
			 "mr_larry_says": "YES! The best deal in the world is still a bad deal if you don't need it. That's the difference between spending and wasting.",
			 "badge": "Impulse Control"},
			{"label": "Buy one pair — $20", "score": 10, "budget_cost": 20,
			 "consequence": "You bought shoes you didn't really need. They look cool though!",
			 "mr_larry_says": "BOGO means Buy One Get One — but the first one still costs $20! You spent $20 on something you didn't plan for.",
			 "fun_impact": 5},
			{"label": "Buy both pairs — $20 for two!", "score": 0, "budget_cost": 20,
			 "consequence": "Two pairs of shoes for $20! Great deal... on something you didn't need at all.",
			 "mr_larry_says": "You 'saved' $20 but SPENT $20 on shoes you don't need. That's not saving — that's spending with extra steps!"},
		]
	},
	{
		"id": "random_school_trip",
		"title": "School Field Trip",
		"description": "There's a field trip to the science museum! It costs $8 plus you'll want money for the gift shop.",
		"mr_larry_intro": "Experiences vs. things — that's a great financial question. How much should you budget for this trip?",
		"options": [
			{"label": "Pay $8 for the trip, bring $5 for the shop", "score": 20, "budget_cost": 13,
			 "consequence": "Great trip! You got a cool souvenir AND stayed within a reasonable budget.",
			 "mr_larry_says": "Setting a budget BEFORE the trip is key! You decided how much to spend before the gift shop tempted you. That's planning!",
			 "fun_impact": 20, "social_impact": 10},
			{"label": "Pay $8 for the trip, skip the gift shop", "score": 15, "budget_cost": 8,
			 "consequence": "Fun trip! You saved $5 by skipping souvenirs. The memories are free!",
			 "mr_larry_says": "The experience IS the reward! You don't need a $5 keychain to remember a great day.",
			 "fun_impact": 15, "social_impact": 10},
			{"label": "Skip the trip — save the money", "score": 5, "budget_cost": 0,
			 "consequence": "You saved money but missed out on a fun day with friends.",
			 "mr_larry_says": "Saving is important, but so are experiences! Sometimes spending on memories is the best investment you can make.",
			 "social_impact": -10},
		]
	},
	{
		"id": "random_chore_bonus",
		"title": "Bonus Chore Opportunity!",
		"description": "Your neighbor needs help raking leaves. They'll pay $8 for an hour of work. But you were going to play video games...",
		"mr_larry_intro": "Time vs. money — the classic tradeoff. What's your hour worth?",
		"options": [
			{"label": "Take the job — earn $8", "score": 20, "budget_cost": -8,
			 "consequence": "Hard work pays! You earned $8 and your neighbor is grateful.",
			 "mr_larry_says": "Earned income! This is how it starts — seeing opportunities and taking them. Your work ethic will serve you for life.",
			 "energy_impact": -15, "social_impact": 5},
			{"label": "Play games instead — $0", "score": 5, "budget_cost": 0,
			 "consequence": "Fun afternoon! But no extra money this week.",
			 "mr_larry_says": "Rest and fun matter too! But notice the tradeoff — one hour of work = $8. That's the opportunity cost of leisure.",
			 "fun_impact": 20},
			{"label": "Offer to do it for $12", "score": 15, "budget_cost": -12,
			 "consequence": "Negotiation skills! Your neighbor agreed to $10. You earned $10!",
			 "mr_larry_says": "You negotiated! That's a business skill. You asked for $12, got $10 — still $2 more than the original offer. Know your worth!",
			 "energy_impact": -15},
		]
	},
]


func get_random_event(completed: Array) -> Dictionary:
	var available: Array[Dictionary] = []
	for event in events:
		if event.id not in completed:
			available.append(event)
	if available.is_empty():
		return {}
	return available[randi() % available.size()]
