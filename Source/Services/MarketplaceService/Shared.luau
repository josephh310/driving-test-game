--[[
    @Title: Marketplace Service (Shared)
    @Author: Joseph (BreakLoop)
    @Description: Shared marketplace configuration defining product IDs, purchase types, intent types, and error codes.
]]

local MarketplaceShared = {}

MarketplaceShared.intent_types = {
	normal = 1,
	gift = 2,
}

MarketplaceShared.product_types = {
	single_purchase = 1,
	multi_purchase = 2,
}

MarketplaceShared.products = {
	-- Single-purchase
	exclusive_vehicles = {
		product_id = 3517122956,
		purchase_type = MarketplaceShared.product_types.single_purchase,
	},
	plate_customisation = {
		product_id = 3517287703,
		purchase_type = MarketplaceShared.product_types.single_purchase,
	},
	speed_boost = {
		product_id = 3517122860,
		purchase_type = MarketplaceShared.product_types.single_purchase,
	},
	color_customisation = {
		product_id = 3517287554,
		purchase_type = MarketplaceShared.product_types.single_purchase,
	},
	vip_pass = {
		product_id = 3517122426,
		purchase_type = MarketplaceShared.product_types.single_purchase,
	},
	starter_pack = {
		product_id = 3517287828,
		purchase_type = MarketplaceShared.product_types.single_purchase,
	},

	-- Multi-purchase
	skip_1 = {
		product_id = 3517120513,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
	skip_5 = {
		product_id = 3517120904,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
	skip_10 = {
		product_id = 3517120754,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
	skip_30 = {
		product_id = 3517121010,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
	skip_to_end = {
		product_id = 3517121647,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
	troll_everyone = {
		product_id = 3517122310,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
	troll_individual = {
		product_id = 3517287382,
		purchase_type = MarketplaceShared.product_types.multi_purchase,
	},
}

MarketplaceShared.error_codes = {
	already_owned = "You already own this product!",
	insufficient_funds = "Insufficient Robux",
	purchase_cancelled = "Purchase was cancelled",
	product_not_found = "Product not found",
	invalid_recipient = "Invalid gift recipient",
	cannot_gift_to_self = "Cannot gift to yourself",
	recipient_owns_product = "Recipient already owns this gamepass",
	marketplace_service_down = "Marketplace service is currently unavailable",
	unknown_error = "An unknown error occurred",
}

return MarketplaceShared
